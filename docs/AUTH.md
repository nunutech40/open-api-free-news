# Authentication Architecture & Logic

## 1. Bagaimana Token Bekerja (Fondasi)

1. User login → BE verifikasi credential → BE buat JWT pair
2. JWT pair disimpan di tabel `tokens` (BE) DAN di SecureStorage (HP)
3. Setiap request ke protected endpoint:
   - HP kirim: `Authorization: Bearer <accessToken>`
   - BE match token dengan DB → valid → proses request
4. `accessToken` expired (15 menit):
   - HP kirim `refreshToken` ke `POST /auth/refresh`
   - BE revoke token lama di DB → issue token pair baru
   - HP simpan token baru, lanjut request
5. `refreshToken` expired (7 hari) → paksa logout → user login ulang

> Password di DB adalah **bcrypt hash**, bukan teks asli.
> BE tidak pernah tahu password asli — hanya membandingkan hash.

### Visualisasi Penyimpanan Token

Setelah login sukses, token disimpan di dua tempat:

**1. Di Database (Backend):** Tabel `tokens`
| id | user_id | access_token | refresh_token | is_revoked | access_expiry |
|----|---------|--------------|---------------|------------|---------------|
| 1  | 10      | `eyJhbG...`  | `eyJhbG...`   | `false`    | `10:15:00`    |

**2. Di SecureStorage (HP/Client):**
| Key | Value |
|-----|-------|
| `access_token` | `eyJhbG...` |
| `refresh_token` | `eyJhbG...` |

---

## 2. Email/Password Login — Internal Flow

### 2.1. Sequence Diagram (Interaksi Komponen)
```mermaid
sequenceDiagram
    participant Client as Client (HP)
    participant BE as Backend (Go)
    participant DB as Database

    Client->>BE: POST /auth/login {email, password}
    BE->>DB: FindByEmail(email)
    
    alt User Tidak Ditemukan
        DB-->>BE: null
        BE-->>Client: 401 "invalid email or password"
    else User Ditemukan
        DB-->>BE: User data (password_hash)
        BE->>BE: bcrypt.Compare(input, hash)
        
        alt Password Tidak Cocok
            BE-->>Client: 401 "invalid email or password"
        else Password Cocok
            BE->>BE: Generate accessToken (15m)
            BE->>BE: Generate refreshToken (7d)
            BE->>DB: INSERT INTO tokens (...)
            BE-->>Client: 200 { accessToken, refreshToken, user }
        end
    end
```

### 2.2. Flowchart Logic (Logika Percabangan)
```mermaid
flowchart TD
    Start(["POST /auth/login {email, password}"]) --> FindEmail["Cari di DB: FindByEmail"]
    FindEmail --> FoundEmail{"Ketemu?"}
    
    %% Jika tidak ketemu
    FoundEmail -- "Tidak" --> Ret401(["Return 401: invalid email/password"])
    
    %% Jika ketemu
    FoundEmail -- "Ya" --> Compare["bcrypt.Compare(input, hash)"]
    Compare --> IsMatch{"Cocok?"}
    
    %% Jika password salah
    IsMatch -- "Tidak" --> Ret401
    
    %% Jika password benar
    IsMatch -- "Ya" --> IssueTokens["issueTokens: Generate JWT Pair"]
    
    %% Sukses
    IssueTokens --> Ret200(["Return 200: {accessToken, refreshToken, user}"])
    
    %% Styling
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    class Ret200 success;
    class Ret401 error;
```

---

## 3. Hybrid OAuth Social Login Architecture (Google, GitHub, Twitter)

Aplikasi ini sengaja menggunakan arsitektur **Hybrid** untuk Social Login guna mengatasi masalah dependensi dan memastikan keandalan di semua platform (Android & iOS).

### 3.1. Mengapa Hybrid?
1. **Google Sign-In (Native):** Menggunakan package `google_sign_in` yang berkomunikasi langsung dengan Google Play Services (Android) dan Apple Authentication (iOS). Ini memberikan UX terbaik tanpa perlu membuka browser (Webview). Token yang didapat adalah **Raw Google ID Token**.
2. **GitHub & Twitter (Firebase Auth):** Menggunakan package `firebase_auth` yang memunculkan Webview (Chrome Custom Tabs / Safari View Controller). Keduanya disatukan oleh Firebase, sehingga aplikasi tidak perlu repot menyimpan puluhan *client secret*. Token yang didapat adalah **Firebase ID Token**.

### 3.2. Sequence Diagram (Interaksi Komponen)
```mermaid
sequenceDiagram
    participant App as Aplikasi Flutter
    participant Native as Google SDK (Native)
    participant FB as Firebase Auth SDK (Webview)
    participant BE as Backend (Go)
    participant DB as Database

    alt Login via Google
        App->>Native: Login via Google Sign-In
        Native-->>App: Return `raw_google_id_token`
        App->>BE: POST /auth/oauth {provider: "google", idToken: raw_google_id_token}
        BE->>BE: idtoken.Validate() (Google API Client)
    else Login via GitHub / Twitter
        App->>FB: signInWithProvider (Webview)
        FB-->>App: Return `firebase_id_token`
        App->>BE: POST /auth/oauth {provider: "github/twitter", idToken: firebase_id_token}
        BE->>BE: fbAuth.VerifyIDToken() (Firebase Admin SDK)
    end
    
    alt Token Invalid / Expired
        BE-->>App: 401 Unauthorized
    else Token Valid
        BE->>BE: Ekstrak Data {email, name, provider_id}
        BE->>DB: Cari User (by google_id/firebase_uid atau email)
        
        alt User Belum Ada
            BE->>DB: INSERT user baru (password=NULL)
        else User Sudah Ada
            BE->>DB: UPDATE provider_id (Account Linking)
        end
        
        BE->>BE: Generate accessToken & refreshToken (JWT Internal BE)
        BE->>DB: INSERT INTO tokens (...)
        BE-->>App: 200 { accessToken, refreshToken, user }
    end
```

### 3.3. Flowchart Logic (Validasi Backend)
```mermaid
flowchart TD
    Start(["POST /auth/oauth {provider, idToken}"]) --> CekProvider{"Provider == 'google' ?"}
    
    %% Branch Google
    CekProvider -- "Ya" --> ValGoogle["idtoken.Validate<br/>(Raw Google Token)"]
    ValGoogle --> IsValidG{"Token Valid?"}
    IsValidG -- "Tidak" --> Ret401(["Return 401 Unauthorized"])
    IsValidG -- "Ya" --> GetGoogle["Dapat: email, name, google_id"]
    GetGoogle --> FindG["Cari di DB: FindByGoogleID"]
    
    %% Branch Firebase (GitHub/Twitter)
    CekProvider -- "Tidak" --> ValFB["fbAuth.VerifyIDToken<br/>(Firebase Admin SDK)"]
    ValFB --> IsValidF{"Token Valid?"}
    IsValidF -- "Tidak" --> Ret401
    IsValidF -- "Ya" --> GetFB["Dapat: email, name, firebase_uid"]
    GetFB --> FindF["Cari di DB: FindByFirebaseUID"]
    
    %% Unified Flow
    FindG --> Found{"Ketemu?"}
    FindF --> Found
    
    %% Returning User
    Found -- "Ya (User Lama)" --> IssueTokens["issueTokens: Generate JWT Pair"]
    
    %% Fallback ke Email
    Found -- "Tidak" --> FindEmail["Cari di DB: FindByEmail"]
    FindEmail --> FoundEmail{"Ketemu?"}
    
    %% Account Linking
    FoundEmail -- "Ya (Email Ada)" --> LinkAcc["Link Account (UPDATE google_id / firebase_uid)"]
    LinkAcc --> IssueTokens
    
    %% Registrasi Baru
    FoundEmail -- "Tidak (Baru)" --> CreateUser["INSERT users (password=NULL)"]
    CreateUser --> IssueTokens
    
    %% Sukses
    IssueTokens --> Ret200(["Return 200: {accessToken, refreshToken, user}"])
    
    %% Styling
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    class Ret200 success;
    class Ret401 error;
```

> **Catatan Penting:** Meskipun metodenya (Native vs Firebase) berbeda di *frontend* dan *backend*, hasil akhirnya tetap sama: Backend memberikan **Internal JWT Access Token**. Aplikasi Flutter tidak peduli user login lewat jalur apa, JWT yang diterima tetap diperlakukan sama untuk request ke endpoint lain.

---

## 4. DB Migration untuk Unified Firebase Social Login

```sql
-- Migration: 011_add_oauth_support.sql (Versi Awal)
-- ... [Disembunyikan untuk keringkasan] ...

-- Migration: 013_add_firebase_uid.sql (Versi Unified)
ALTER TABLE users ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(255) UNIQUE DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users (firebase_uid);

-- Update constraint untuk mendukung twitter
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_auth_provider;
ALTER TABLE users ADD CONSTRAINT chk_auth_provider
    CHECK (auth_provider IN ('local', 'google', 'apple', 'github', 'twitter'));
```

**Kolom relevan di tabel `users`:**

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `password` | TEXT **NULL** | Diubah dari NOT NULL — NULL untuk social user |
| `firebase_uid` | VARCHAR(255) UNIQUE NULL | `uid` dari Firebase Admin SDK |
| `auth_provider` | VARCHAR(20) DEFAULT 'local' | `local` / `google` / `apple` / `github` / `twitter` |

---

## 5. Lupa Password (Forgot Password) via Firebase OTP

Fitur ini mengizinkan pengguna yang tidak bisa login (lupa password) untuk mereset password mereka dengan melakukan verifikasi nomor HP menggunakan **Firebase Phone Auth** (OTP SMS). Ini adalah API Public (tanpa Bearer Token) karena user dalam kondisi belum login.

### 5.1. Syarat Infrastruktur
- Menggunakan **Firebase Admin SDK** di Backend Go (`firebase.google.com/go/v4`).
- Tabel `users` wajib memiliki kolom `phone` yang terisi dengan format E.164 (contoh: `+628111111111`).

### 5.2. Sequence Diagram (Interaksi Komponen)

```mermaid
sequenceDiagram
    participant App as Aplikasi Flutter
    participant FB as Firebase Server
    participant BE as Backend (Go)
    participant DB as Database

    App->>FB: Request OTP SMS ke Nomor HP
    FB-->>App: SMS Terkirim
    App->>FB: Verifikasi kode OTP
    FB-->>App: Return `firebase_id_token`
    
    Note over App, BE: App kirim token Firebase ke BE untuk dipastikan keasliannya
    App->>BE: POST /auth/password/forgot {firebase_id_token, new_password}
    BE->>FB: Verifikasi `firebase_id_token` (Admin SDK)
    
    alt Token Invalid / Expired
        FB-->>BE: Error
        BE-->>App: 401 Unauthorized
    else Token Valid
        FB-->>BE: Data Token {phone_number}
        BE->>DB: Cari User (FindUserByPhone)
        
        alt Nomor HP Belum Terdaftar
            BE-->>App: 404 User Not Found
        else Nomor HP Ditemukan
            BE->>BE: Hash `new_password` dengan bcrypt
            BE->>DB: UPDATE users SET password = hash WHERE phone = phone_number
            BE-->>App: 200 Password Changed Successfully
        end
    end
```

### 5.3. Flowchart Logic

```mermaid
flowchart TD
    Start(["POST /auth/password/forgot {firebase_token, new_pass}"]) --> VerifyToken["Verifikasi token ke Firebase"]
    VerifyToken --> IsTokenValid{"Valid?"}
    
    IsTokenValid -- "Tidak" --> Ret401(["Return 401: Invalid Firebase Token"])
    IsTokenValid -- "Ya" --> GetPhone["Dapat phone_number (+62...)"]
    
    GetPhone --> FindDB["Cari di DB: FindByPhone"]
    FindDB --> IsFound{"Ketemu?"}
    
    IsFound -- "Tidak" --> Ret404(["Return 404: User Not Found"])
    IsFound -- "Ya" --> HashPass["Hash new_pass (bcrypt)"]
    
    HashPass --> UpdateDB["UPDATE users SET password = hash"]
    UpdateDB --> Ret200(["Return 200: Success"])
    
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    class Ret200 success;
    class Ret401,Ret404 error;
```

### 5.4. Bagaimana Backend Go Memverifikasi Token Firebase?

Salah satu pertanyaan kritis adalah: *"Jika Backend Go tidak pernah menyimpan `firebase_id_token` dari OTP di database, bagaimana cara Go mencocokkannya?"*

Jawabannya adalah: **Go tidak mencocokkan token, melainkan memverifikasi Tanda Tangan Kriptografi (Digital Signature).**

`idToken` Firebase adalah sebuah JWT (JSON Web Token) yang dibentuk oleh konsep Kriptografi Asimetris.
1. **Firebase Membuat Surat:** Setelah user memasukkan OTP yang benar di aplikasi Flutter, Firebase membuatkan `idToken` (surat keterangan) yang berisi nomor HP user.
2. **Stempel Emas (Private Key):** Firebase memberikan "stempel emas" pada surat tersebut menggunakan *Private Key* yang hanya dimiliki oleh Google.
3. **Go Mengecek Keaslian (Public Key):** Aplikasi Flutter mengirim surat ini ke Backend Go. Menggunakan **Firebase Admin SDK**, Backend Go men-download buku panduan *Public Key* milik Google dari internet. Go secara matematis mengecek apakah "stempel emas" di surat tersebut benar-benar dicetak oleh Google dan belum kedaluwarsa.
4. **Ekstrak Nomor HP:** Jika stempelnya terbukti asli (Valid), Go akan mengambil informasi nomor HP dari dalam surat tersebut (misal: `+628111111111`). Surat/token tersebut kemudian dibuang.
5. **Pencarian Database:** Langkah terakhir, Backend Go mencari di tabel `users` miliknya sendiri: `SELECT * FROM users WHERE phone = '+628111111111'`. Jika user ditemukan, password-nya akan diubah.

Dengan arsitektur ini, Backend Go tidak perlu repot menyimpan kode OTP atau token verifikasi. Semua beban verifikasi OTP (pengiriman SMS dan validasi kode angka) di-*outsource* sepenuhnya ke infrastruktur Firebase.

