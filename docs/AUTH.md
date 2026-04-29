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

## 3. Google Sign-In — Internal Flow (Planned)

Perbedaan mendasar: **Google yang memverifikasi identitas**, bukan BE.
`idToken` adalah "surat keterangan dari Google" yang berisi: *email, name, googleId*.
BE memvalidasi surat ini ke server Google — tidak ada password yang dicek.

### 3.1. Sequence Diagram (Interaksi Komponen)
```mermaid
sequenceDiagram
    participant Client as Client (HP)
    participant Google as Google Server
    participant BE as Backend (Go)
    participant DB as Database

    Client->>Google: Login via Native OS Popup
    Google-->>Client: Return `idToken`
    
    Client->>BE: POST /auth/oauth {provider, idToken}
    BE->>Google: Verifikasi idToken ke OAuth API
    
    alt Token Invalid / Expired
        Google-->>BE: Error
        BE-->>Client: 401 Unauthorized
    else Token Valid
        Google-->>BE: Data {email, name, googleId}
        BE->>DB: Cari User (by googleId atau email)
        
        alt User Belum Ada
            BE->>DB: INSERT user baru (password=NULL)
        else User Sudah Ada
            BE->>DB: UPDATE google_id (Account Linking)
        end
        
        BE->>BE: Generate accessToken & refreshToken
        BE->>DB: INSERT INTO tokens (...)
        BE-->>Client: 200 { accessToken, refreshToken, user }
    end
```

### 3.2. Flowchart Logic (Logika Percabangan)
```mermaid
flowchart TD
    Start(["POST /auth/oauth {provider, idToken}"]) --> Verify["Kirim idToken ke Google API"]
    Verify --> IsValid{"Token Valid?"}
    
    %% Jika Invalid
    IsValid -- "Tidak" --> Ret401(["Return 401 Unauthorized"])
    
    %% Jika Valid
    IsValid -- "Ya" --> GetGoogleData["Dapat: email, name, googleId"]
    GetGoogleData --> FindGId["Cari di DB: FindByGoogleID"]
    FindGId --> FoundGId{"Ketemu?"}
    
    %% Returning Google User
    FoundGId -- "Ya (User Lama Google)" --> IssueTokens["issueTokens: Generate JWT Pair"]
    
    %% Fallback ke Email
    FoundGId -- "Tidak" --> FindEmail["Cari di DB: FindByEmail"]
    FindEmail --> FoundEmail{"Ketemu?"}
    
    %% Account Linking
    FoundEmail -- "Ya (User Lama Email)" --> LinkAcc["UPDATE users SET google_id = googleId"]
    LinkAcc --> IssueTokens
    
    %% Registrasi Baru
    FoundEmail -- "Tidak (User Baru)" --> CreateUser["INSERT users<br>(password=NULL, auth_provider='google')"]
    CreateUser --> IssueTokens
    
    %% Sukses
    IssueTokens --> Ret200(["Return 200: {accessToken, refreshToken, user}"])
    
    %% Styling
    classDef success fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef error fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    class Ret200 success;
    class Ret401 error;
```

> Setelah dapat `accessToken` dari BE, HP menyimpan dan menggunakannya
> **persis sama** seperti login email/password. Client tidak perlu tahu
> user login via metode apa — semuanya transparan.

---

## 4. DB Migration untuk Google Sign-In

```sql
-- Migration: 011_add_oauth_support.sql

-- 1. password jadi nullable (Google user tidak punya password)
ALTER TABLE users ALTER COLUMN password DROP NOT NULL;
ALTER TABLE users ALTER COLUMN password SET DEFAULT NULL;

-- 2. simpan Google ID untuk lookup returning user
ALTER TABLE users ADD COLUMN IF NOT EXISTS
    google_id VARCHAR(255) UNIQUE DEFAULT NULL;

-- 3. track metode registrasi
ALTER TABLE users ADD COLUMN IF NOT EXISTS
    auth_provider VARCHAR(20) NOT NULL DEFAULT 'local';

ALTER TABLE users ADD CONSTRAINT chk_auth_provider
    CHECK (auth_provider IN ('local', 'google', 'apple', 'github'));

CREATE INDEX IF NOT EXISTS idx_users_google_id ON users (google_id);
```

**Kolom baru di tabel `users`:**

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `password` | TEXT **NULL** | Diubah dari NOT NULL — NULL untuk social user |
| `google_id` | VARCHAR(255) UNIQUE NULL | `sub` dari Google idToken |
| `auth_provider` | VARCHAR(20) DEFAULT 'local' | `local` / `google` / `apple` / `github` |

