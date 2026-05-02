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

## 3. Unified Firebase Social Login — Internal Flow (Google, GitHub, Twitter)

Perbedaan mendasar: **Firebase yang memverifikasi identitas**, bukan BE secara manual.
`idToken` yang dikirim dari Flutter adalah `Firebase ID Token`, yaitu JWT (JSON Web Token) yang ditandatangani oleh Firebase.
BE memvalidasi token ini menggunakan Firebase Admin SDK — tidak ada password atau token raw dari masing-masing provider (Google/GitHub/X) yang dicek secara langsung oleh BE.

### 3.1. Sequence Diagram (Interaksi Komponen)
```mermaid
sequenceDiagram
    participant App as Aplikasi Flutter
    participant FB as Firebase Auth SDK / Webview
    participant BE as Backend (Go)
    participant DB as Database

    App->>FB: Login via Provider (Google/GitHub/X)
    FB-->>App: Return `firebase_id_token`
    
    Note over App, BE: App TIDAK kirim token mentah provider.<br/>Hanya kirim token Firebase!
    App->>BE: POST /auth/oauth {provider, idToken: firebase_id_token}
    BE->>BE: fbAuth.VerifyIDToken() (Firebase Admin SDK)
    
    alt Token Invalid / Expired
        BE-->>App: 401 Unauthorized
    else Token Valid
        BE->>BE: Ekstrak Data {email, name, firebase_uid}
        BE->>DB: Cari User (by firebase_uid atau email)
        
        alt User Belum Ada
            BE->>DB: INSERT user baru (password=NULL, firebase_uid)
        else User Sudah Ada
            BE->>DB: UPDATE firebase_uid (Account Linking)
        end
        
        BE->>BE: Generate accessToken & refreshToken (JWT Internal BE)
        BE->>DB: INSERT INTO tokens (...)
        BE-->>App: 200 { accessToken, refreshToken, user }
    end
```

### 3.2. Flowchart Logic (Logika Percabangan)
```mermaid
flowchart TD
    Start(["POST /auth/oauth {provider, firebaseToken}"]) --> Verify["VerifyIDToken (Firebase Admin SDK)"]
    Verify --> IsValid{"Token Valid?"}
    
    %% Jika Invalid
    IsValid -- "Tidak" --> Ret401(["Return 401 Unauthorized"])
    
    %% Jika Valid
    IsValid -- "Ya" --> GetData["Dapat: email, name, firebase_uid"]
    GetData --> FindFB["Cari di DB: FindByFirebaseUID"]
    FindFB --> FoundFB{"Ketemu?"}
    
    %% Returning User
    FoundFB -- "Ya (User Lama)" --> IssueTokens["issueTokens: Generate JWT Pair"]
    
    %% Fallback ke Email
    FoundFB -- "Tidak" --> FindEmail["Cari di DB: FindByEmail"]
    FindEmail --> FoundEmail{"Ketemu?"}
    
    %% Account Linking
    FoundEmail -- "Ya (Email Ada)" --> LinkAcc["UPDATE users SET firebase_uid = firebase_uid"]
    LinkAcc --> IssueTokens
    
    %% Registrasi Baru
    FoundEmail -- "Tidak (Baru)" --> CreateUser["INSERT users<br>(password=NULL, firebase_uid)"]
    CreateUser --> IssueTokens
    
    %% Sukses
    IssueTokens --> Ret200(["Return 200: {accessToken, refreshToken, user}"])
    
    %% Styling
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    class Ret200 success;
    class Ret401 error;
```

> Setelah dapat `accessToken` internal dari BE, HP menyimpan dan menggunakannya
> **persis sama** seperti login email/password. Client tidak perlu tahu
> user login via metode apa — semuanya transparan.

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

