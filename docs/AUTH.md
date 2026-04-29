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

---

## 2. Email/Password Login — Internal Flow

```text
POST /auth/login { email, password }
  │
  ├── FindByEmail(email) → dapat user dari DB
  │     └── tidak ketemu → return "invalid email or password"
  │
  ├── bcrypt.Compare(inputPassword, user.password_hash)
  │     └── tidak cocok  → return "invalid email or password"
  │
  └── issueTokens(user)
        ├── GenerateJWT({ userId, email, role }) → accessToken  (15m)
        ├── GenerateJWT({ userId })              → refreshToken (7d)
        ├── INSERT INTO tokens (user_id, access_token, refresh_token, ...)
        └── return { accessToken, refreshToken, user }
```

---

## 3. Google Sign-In — Internal Flow (Planned)

Perbedaan mendasar: **Google yang memverifikasi identitas**, bukan BE.
`idToken` adalah "surat keterangan dari Google" yang berisi: *email, name, googleId*.
BE memvalidasi surat ini ke server Google — tidak ada password yang dicek.

```text
POST /auth/oauth { provider: "google", id_token: "eyJ..." }
  │
  ├── Kirim idToken ke https://oauth2.googleapis.com/tokeninfo
  │     ├── valid   → dapat { email, name, sub: googleId }
  │     └── invalid → return 401 Unauthorized
  │
  ├── FindByGoogleID(googleId)
  │     ├── Ketemu → issueTokens(user)          ← returning Google user
  │     └── Tidak ketemu → FindByEmail(email)
  │           ├── Ketemu (user lama pakai email)
  │           │     └── UPDATE users SET google_id = googleId
  │           │         link akun → issueTokens(user)
  │           └── Tidak ketemu (user baru)
  │                 └── INSERT users {
  │                       name, email, google_id,
  │                       password    = NULL,
  │                       auth_provider = 'google'
  │                     }
  │                     issueTokens(newUser)
  │
  └── return { accessToken, refreshToken, user }
      ← format IDENTIK dengan login biasa
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

