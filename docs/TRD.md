# Technical Requirements Document (TRD)
## RootAppNews — News Feature Backend

| Field        | Value                             |
|--------------|-----------------------------------|
| Version      | 1.0.0                             |
| Referensi    | PRD v1.0.0                        |
| Author       | RootAppNews Team                  |
| Last Updated | 2026-04-01                        |
| Status       | Draft                             |

---

## 1. Tech Stack

| Komponen       | Teknologi                          |
|----------------|------------------------------------|
| Bahasa         | Go 1.22+                           |
| Database       | PostgreSQL 15+                     |
| HTTP Framework | (sesuai go.mod yang terinstal)     |
| Auth           | JWT (sudah ada, iterasi sebelumnya)|
| Image Hosting  | External URL (Cloudinary/Supabase) |
| Migration      | Manual SQL (`migrations/`)         |

---

## 2. Skema Database (Actual — Verified dari PostgreSQL Live)

> Schema di bawah diverifikasi langsung dari DB live via `\d <table>` pada 2026-04-29.

### 2.1. Tabel `users`

```sql
-- Gabungan: migration 001 + 005 + 009
CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100)             NOT NULL,
    email       VARCHAR(255)             NOT NULL UNIQUE,
    password    TEXT                     NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    role        VARCHAR(20)              NOT NULL DEFAULT 'user',  -- 'user' | 'admin'
    avatar_url  VARCHAR(255)             DEFAULT '',
    bio         TEXT                     DEFAULT '',
    phone       VARCHAR(50)              DEFAULT '',
    preferences JSONB                    DEFAULT '{}'::jsonb
);

CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_role  ON users (role);

-- Constraint
ALTER TABLE users ADD CONSTRAINT chk_users_role CHECK (role IN ('user', 'admin'));
```

### 2.2. Tabel `tokens`

```sql
-- Migration: 002_create_tokens_table.sql
CREATE TABLE IF NOT EXISTS tokens (
    id             BIGSERIAL PRIMARY KEY,
    user_id        BIGINT                   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token   TEXT                     NOT NULL,
    refresh_token  TEXT                     NOT NULL UNIQUE,
    access_expiry  TIMESTAMP WITH TIME ZONE NOT NULL,
    refresh_expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked     BOOLEAN                  NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tokens_user_id       ON tokens (user_id);
CREATE INDEX idx_tokens_refresh_token ON tokens (refresh_token);
CREATE INDEX idx_tokens_is_revoked    ON tokens (is_revoked);
```

### 2.3. Tabel `categories`

```sql
-- Migration: 003_create_categories_table.sql
CREATE TABLE IF NOT EXISTS categories (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100)             NOT NULL,
    slug        VARCHAR(100)             NOT NULL UNIQUE,
    is_active   BOOLEAN                  NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT                     DEFAULT ''   -- ⚠️ Ada di DB, sempat tidak terdokumentasi
);

CREATE INDEX idx_categories_slug      ON categories (slug);
CREATE INDEX idx_categories_is_active ON categories (is_active);
```

### 2.4. Tabel `articles`

```sql
-- Migration: 004_create_articles_table.sql
CREATE TABLE IF NOT EXISTS articles (
    id                BIGSERIAL PRIMARY KEY,
    category_id       BIGINT                   NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    author_id         BIGINT                   NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title             VARCHAR(500)             NOT NULL,
    slug              VARCHAR(500)             NOT NULL UNIQUE,
    excerpt           TEXT,
    content           TEXT                     NOT NULL,
    image_url         TEXT,
    thumbnail_url     TEXT,
    read_time_minutes INTEGER                  NOT NULL DEFAULT 1,
    status            VARCHAR(20)              NOT NULL DEFAULT 'draft', -- draft | published | archived
    published_at      TIMESTAMP WITH TIME ZONE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_articles_category_id  ON articles (category_id);
CREATE INDEX idx_articles_author_id    ON articles (author_id);
CREATE INDEX idx_articles_slug         ON articles (slug);
CREATE INDEX idx_articles_status       ON articles (status);
CREATE INDEX idx_articles_published_at ON articles (published_at DESC);

ALTER TABLE articles ADD CONSTRAINT chk_articles_status
    CHECK (status IN ('draft', 'published', 'archived'));
```

### 2.5. Entity Relationship

```
users  (1) ──────────── (N)  tokens        [CASCADE DELETE]
users  (1) ──────────── (N)  articles      [RESTRICT DELETE]
categories (1) ────── (N)  articles        [RESTRICT DELETE]
```

---

## 3. Domain Layer (Go Struct)

Ikuti pola yang sudah ada di `internal/domain/`. Tambahkan file baru:

### `internal/domain/news.go`
```go
package domain

import (
    "context"
    "time"
)

// Category adalah entitas kategori berita
type Category struct {
    ID        int64     `json:"id"`
    Name      string    `json:"name"`
    Slug      string    `json:"slug"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}

// Article adalah entitas artikel berita
type Article struct {
    ID              int64      `json:"id"`
    CategoryID      int64      `json:"category_id"`
    CategoryName    string     `json:"category_name"` // join dari tabel categories
    AuthorID        int64      `json:"author_id"`
    AuthorName      string     `json:"author_name"`   // join dari tabel users
    Title           string     `json:"title"`
    Slug            string     `json:"slug"`
    Excerpt         string     `json:"excerpt"`
    Content         string     `json:"content,omitempty"` // omit saat list, tampilkan di detail
    ImageURL        string     `json:"image_url"`
    ThumbnailURL    string     `json:"thumbnail_url,omitempty"`
    ReadTimeMinutes int        `json:"read_time_minutes"`
    Status          string     `json:"status"`
    PublishedAt     *time.Time `json:"published_at"`
    CreatedAt       time.Time  `json:"created_at"`
    UpdatedAt       time.Time  `json:"updated_at"`
}

// NewsFeedResponse adalah struktur response yang sudah ditata untuk UI Hero+Grid Flutter
type NewsFeedResponse struct {
    HeroArticle  *Article  `json:"hero_article"`   // nil jika include_hero=false
    FeedArticles []*Article `json:"feed_articles"`
    Meta         *PaginationMeta `json:"meta"`
}

// PaginationMeta untuk informasi paginasi
type PaginationMeta struct {
    CurrentPage int   `json:"current_page"`
    TotalPages  int   `json:"total_pages"`
    TotalItems  int64 `json:"total_items"`
    Limit       int   `json:"limit"`
}

// CreateArticleRequest untuk input pembuatan artikel (admin)
type CreateArticleRequest struct {
    CategoryID   int64  `json:"category_id"   validate:"required"`
    Title        string `json:"title"          validate:"required,min=5,max=500"`
    Excerpt      string `json:"excerpt"        validate:"max=500"`
    Content      string `json:"content"        validate:"required,min=50"`
    ImageURL     string `json:"image_url"      validate:"omitempty,url"`
    ThumbnailURL string `json:"thumbnail_url"  validate:"omitempty,url"`
    Status       string `json:"status"         validate:"oneof=draft published"`
}

// NewsFeedQuery adalah parameter filter untuk endpoint feed
type NewsFeedQuery struct {
    Category    string // slug kategori, kosong = semua kategori
    Page        int    // default: 1
    Limit       int    // default: 10, max: 50
    IncludeHero bool   // jika true, artikel pertama dipisah sebagai hero_article
}
```

---

## 4. Spesifikasi Endpoint API

### Base URL: `/api/v1`

---

### 4.0. Auth Endpoints

#### `POST /auth/register`

**Auth:** 🔓 Public (No Auth)  
**Request:**
```json
{ "name": "Nunu", "email": "nunu@mail.com", "password": "secret123" }
```
**Response 201:**
```json
{
  "status": "success",
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "access_expiry": "2026-04-29T10:15:00Z",
    "user": { "id": 1, "name": "Nunu", "email": "nunu@mail.com", "role": "user" }
  }
}
```

#### `POST /auth/login`

**Auth:** 🔓 Public (No Auth)  
**Request:**
```json
{ "email": "nunu@mail.com", "password": "secret123" }
```
**Response 200:** Format sama dengan register.

#### `POST /auth/refresh`

**Auth:** 🔓 Public — kirim refresh_token di body  
**Request:**
```json
{ "refresh_token": "eyJ..." }
```
**Logic:** Revoke token lama → issue token pair baru.  
**Response 200:** Format sama dengan login.

#### `POST /auth/logout`

**Auth:** 🔓 Public — kirim refresh_token di body  
**Request:**
```json
{ "refresh_token": "eyJ..." }
```
**Response 200:**
```json
{ "status": "success", "message": "logged out" }
```

#### `GET /auth/me`

**Auth:** 🔒 Private (Bearer JWT)  
**Response 200:**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Nunu Nugraha",
    "email": "nunu@rootapp.com",
    "role": "user",
    "avatar_url": "http://103.181.143.73:8080/uploads/avatar_1.jpg",
    "bio": "Flutter developer",
    "phone": "08123456789",
    "preferences": "{}",
    "created_at": "2026-04-01T00:00:00Z"
  }
}
```

#### `PUT /auth/me`

**Auth:** 🔒 Private (Bearer JWT)  
**Request:**
```json
{ "name": "Nunu Updated", "bio": "Senior Flutter Dev", "phone": "0812", "avatar_url": "", "preferences": "" }
```
**Response 200:** Format sama dengan `GET /auth/me`.

#### `POST /auth/upload-avatar`

**Auth:** 🔒 Private (Bearer JWT)  
**Content-Type:** `multipart/form-data`  
**Field:** `avatar` (file image)  
**Response 200:**
```json
{ "status": "success", "data": { "avatar_url": "http://103.181.143.73:8080/uploads/avatar_1.jpg" } }
```

#### `POST /auth/oauth` *(Planned — Google Sign-In)*

**Auth:** 🔓 Public (No Auth)  
**Request:**
```json
{ "provider": "google", "id_token": "eyJ..." }
```
**Response 200:** Format sama dengan login.

> [!IMPORTANT]
> Endpoint ini **belum diimplementasi**. Lihat Section 4.0.1 untuk detail logic dan migration yang dibutuhkan.

---

### 4.0.1. Auth Logic Deep-Dive

#### A. Bagaimana Token Bekerja (Fondasi)

```
1. User login → BE verifikasi credential → BE buat JWT pair
2. JWT pair disimpan di tabel `tokens` (BE) DAN di SecureStorage (HP)
3. Setiap request ke protected endpoint:
   - HP kirim: Authorization: Bearer <accessToken>
   - BE match token dengan DB → valid → proses request
4. accessToken expired (15 menit):
   - HP kirim refreshToken ke POST /auth/refresh
   - BE revoke token lama di DB → issue token pair baru
   - HP simpan token baru, lanjut request
5. refreshToken expired (7 hari) → paksa logout → user login ulang
```

> Password di DB adalah **bcrypt hash**, bukan teks asli.
> BE tidak pernah tahu password asli — hanya membandingkan hash.

#### B. Email/Password Login — Internal Flow

```
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

#### C. Google Sign-In — Internal Flow (Planned)

Perbedaan mendasar: **Google yang memverifikasi identitas**, bukan BE.
`idToken` adalah "surat keterangan dari Google" yang berisi: *email, name, googleId*.
BE memvalidasi surat ini ke server Google — tidak ada password yang dicek.

```
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

#### D. DB Migration untuk Google Sign-In

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

---

### 4.1. `GET /categories`
Mengembalikan semua kategori yang aktif.

**Auth:** 🔓 Public (No Auth)  
**Query Params:** Tidak ada

**Response 200:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Technology",
      "slug": "technology",
      "is_active": true
    },
    {
      "id": 2,
      "name": "Finance",
      "slug": "finance",
      "is_active": true
    }
  ]
}
```

---

### 4.2. `GET /news`
Mengembalikan feed berita terpaginasi.

**Auth:** 🔓 Public (No Auth)  
**Query Params:**

| Param          | Tipe    | Default | Deskripsi                                         |
|----------------|---------|---------|---------------------------------------------------|
| `category`     | string  | `""`    | Slug kategori untuk filter. Kosong = semua.       |
| `page`         | integer | `1`     | Nomor halaman.                                    |
| `limit`        | integer | `10`    | Jumlah artikel per halaman. **Maks 50**.          |
| `include_hero` | boolean | `true`  | Jika `true`, artikel pertama dipisah sebagai Hero. |

**Response 200:**
```json
{
  "status": "success",
  "data": {
    "hero_article": {
      "id": 99,
      "category_name": "World",
      "author_name": "Eleanor Vance",
      "title": "Global Markets Surge as Tech Leaders Chart Future.",
      "slug": "global-markets-surge-tech-leaders",
      "excerpt": "The world's largest economies see significant growth driven by innovations in AI and energy.",
      "image_url": "https://cdn.example.com/images/global-markets-hero.jpg",
      "read_time_minutes": 2,
      "published_at": "2026-04-01T08:21:00Z"
    },
    "feed_articles": [
      {
        "id": 100,
        "category_name": "Technology",
        "author_name": "Andi Purnomo",
        "title": "Apple's AI Leap; The New iPhone 16 Pro",
        "slug": "apples-ai-leap-iphone-16-pro",
        "excerpt": "Cupertino's next flagship redefines on-device intelligence.",
        "image_url": "https://cdn.example.com/images/iphone16pro.jpg",
        "thumbnail_url": "https://cdn.example.com/images/iphone16pro-thumb.jpg",
        "read_time_minutes": 4,
        "published_at": "2026-04-01T09:10:00Z"
      }
    ],
    "meta": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 48,
      "limit": 10
    }
  }
}
```

---

### 4.3. `GET /news/:slug`
Mengembalikan detail satu artikel.

**Auth:** 🔓 Public (No Auth Required)

**Response 200:**
```json
{
  "status": "success",
  "data": {
    "id": 99,
    "category_name": "World",
    "author_name": "Eleanor Vance",
    "title": "Global Markets Surge as Tech Leaders Chart Future.",
    "slug": "global-markets-surge-tech-leaders",
    "excerpt": "The world's largest economies see significant growth...",
    "content": "<p>Konten lengkap artikel dalam format HTML atau markdown...</p>",
    "image_url": "https://cdn.example.com/images/global-markets-hero.jpg",
    "read_time_minutes": 2,
    "published_at": "2026-04-01T08:21:00Z",
    "created_at": "2026-04-01T07:00:00Z"
  }
}
```

**Response 404:**
```json
{
  "status": "error",
  "message": "Article not found"
}
```

---

### 4.4. `POST /admin/articles` *(Requires Admin Role)*
Membuat artikel baru.

**Auth:** 🔒 Private (Bearer JWT + role: admin)

**Request Body:**
```json
{
  "category_id": 1,
  "title": "Apple's AI Leap; The New iPhone 16 Pro",
  "excerpt": "Cupertino's next flagship redefines on-device intelligence.",
  "content": "Konten artikel selengkapnya di sini...",
  "image_url": "https://cdn.example.com/images/iphone16pro.jpg",
  "thumbnail_url": "https://cdn.example.com/images/iphone16pro-thumb.jpg",
  "status": "published"
}
```

**Business Logic saat Insert:**
1. Generate `slug` otomatis dari `title` (lowercase, strip punctuation, ganti spasi dengan `-`).
2. Hitung `read_time_minutes` otomatis: `ceil(word_count / 200)`, minimal 1.
3. Set `published_at = NOW()` jika `status = "published"`, `NULL` jika `draft`.

**Response 201:**
```json
{
  "status": "success",
  "message": "Article created successfully",
  "data": { "id": 101, "slug": "apples-ai-leap-iphone-16-pro" }
}
```

---

### 4.5. `GET /me` *(Sudah Ada — Diperkuat)*
Endpoint ini sudah exist dari iterasi Auth. Respons diperkaya dengan field `role`.

**Auth:** 🔒 Private (Bearer JWT Required)

**Response 200:**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Nunu Nugraha",
    "email": "nunu@rootapp.com",
    "role": "user",
    "created_at": "2026-04-01T00:00:00Z"
  }
}
```

---

## 5. Arsitektur Layer Go

Ikuti pola Clean Architecture yang sudah ada di repositori ini:

```
internal/
├── domain/
│   ├── user.go          (SUDAH ADA)
│   ├── interfaces.go    (SUDAH ADA — perlu tambah interface News)
│   └── news.go          (BARU)
├── repository/
│   ├── user_repo.go     (SUDAH ADA)
│   ├── token_repo.go    (SUDAH ADA)
│   ├── category_repo.go (BARU)
│   └── article_repo.go  (BARU)
├── service/
│   ├── auth_service.go  (SUDAH ADA)
│   └── news_service.go  (BARU)
├── handler/
│   ├── auth_handler.go  (SUDAH ADA)
│   ├── news_handler.go  (BARU)
│   └── admin_handler.go (BARU)
├── middleware/
│   ├── auth.go          (SUDAH ADA)
│   └── admin_only.go    (BARU — cek role admin)
└── router/
    └── router.go        (perlu update tambah route news)
```

---

## 6. Interface Baru (Tambahan di `interfaces.go`)

```go
// CategoryRepository defines data access for categories
type CategoryRepository interface {
    FindAll(ctx context.Context) ([]*Category, error)
    FindBySlug(ctx context.Context, slug string) (*Category, error)
    Create(ctx context.Context, c *Category) (*Category, error)
}

// ArticleRepository defines data access for articles
type ArticleRepository interface {
    FindFeed(ctx context.Context, query *NewsFeedQuery) ([]*Article, int64, error)
    FindBySlug(ctx context.Context, slug string) (*Article, error)
    Create(ctx context.Context, a *Article) (*Article, error)
    Update(ctx context.Context, a *Article) (*Article, error)
}

// NewsService defines news business logic
type NewsService interface {
    GetCategories(ctx context.Context) ([]*Category, error)
    GetFeed(ctx context.Context, query *NewsFeedQuery) (*NewsFeedResponse, error)
    GetArticleBySlug(ctx context.Context, slug string) (*Article, error)
    CreateArticle(ctx context.Context, authorID int64, req *CreateArticleRequest) (*Article, error)
}
```

---

## 7. Business Logic Kritis

### 7.1. Kalkulasi `read_time_minutes`
```go
// utils/read_time.go
func CalculateReadTime(content string) int {
    words := len(strings.Fields(content))
    minutes := int(math.Ceil(float64(words) / 200.0))
    if minutes < 1 {
        return 1
    }
    return minutes
}
```

### 7.2. Auto-generate `slug`
```go
// utils/slug.go
func GenerateSlug(title string) string {
    // 1. Lowercase
    s := strings.ToLower(title)
    // 2. Hapus karakter non-alphanumeric kecuali spasi dan strip
    reg := regexp.MustCompile(`[^a-z0-9\s-]`)
    s = reg.ReplaceAllString(s, "")
    // 3. Ganti spasi dengan strip
    s = strings.ReplaceAll(strings.TrimSpace(s), " ", "-")
    return s
}
```

### 7.3. Middleware Admin Only
```go
// middleware/admin_only.go
func AdminOnly(jwtSecret string) fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Ambil claims dari JWT yang sudah divalidasi AuthMiddleware sebelumnya
        claims := c.Locals("claims").(*JWTClaims)
        if claims.Role != "admin" {
            return c.Status(403).JSON(fiber.Map{
                "status": "error",
                "message": "Forbidden: admin access required",
            })
        }
        return c.Next()
    }
}
```

---

## 8. Routing Update

```go
// Tambahkan di router.go
api := app.Group("/api/v1")

// Public routes — News
api.Get("/categories",  newsHandler.GetCategories)
api.Get("/news",        newsHandler.GetFeed)
api.Get("/news/:slug",  newsHandler.GetArticleBySlug)

// Admin routes — require JWT + role admin
admin := api.Group("/admin", authMiddleware, adminOnlyMiddleware)
admin.Post("/articles",      adminHandler.CreateArticle)
admin.Put("/articles/:id",   adminHandler.UpdateArticle)
```

---

## 9. Error Response Standard

Konsisten dengan format Auth yang sudah ada:

```json
// 400 Bad Request
{ "status": "error", "message": "category is required" }

// 401 Unauthorized
{ "status": "error", "message": "missing or invalid token" }

// 403 Forbidden
{ "status": "error", "message": "Forbidden: admin access required" }

// 404 Not Found
{ "status": "error", "message": "Article not found" }

// 500 Internal Server Error
{ "status": "error", "message": "internal server error" }
```

---

## 10. Urutan Pengerjaan

| Urutan | Task                                               | File Baru       |
|--------|----------------------------------------------------|-----------------|
| 1      | Buat dan jalankan migration DB (tabel + role kolum)| `migrations/`   |
| 2      | Tambah struct & interface domain                   | `domain/news.go`|
| 3      | Implementasi `category_repo.go`                    | `repository/`   |
| 4      | Implementasi `article_repo.go`                     | `repository/`   |
| 5      | Implementasi `news_service.go`                     | `service/`      |
| 6      | Implementasi `news_handler.go` (public)            | `handler/`      |
| 7      | Implementasi `admin_handler.go` + `admin_only.go`  | `handler/` `middleware/` |
| 8      | Update `router.go` dengan route baru               | `router/`       |
| 9      | Test manual via Postman                            | -               |
| 10     | Update collection Postman                          | `*.postman.json`|

## 10. Update Profile & Extension Feature (Added 2026-04-02)

### 10.1 Database Expansion (Migration 009)
Extended `users` table fields:
* `avatar_url` (VARCHAR): User's profile picture.
* `bio` (TEXT): Biographical section.
* `phone` (VARCHAR): Contact Number.
* `preferences` (JSONB): Mapped JSON settings (e.g. `{"theme":"dark"}`).

### 10.2 Domain layer Additions
```go
type UpdateProfileRequest struct {
    Name        string `json:"name" validate:"required,min=2,max=100"`
    AvatarURL   string `json:"avatar_url"`
    Bio         string `json:"bio"`
    Phone       string `json:"phone"`
    Preferences string `json:"preferences"`
}
```

### 10.3 API Endpoints
1. `GET /api/v1/auth/me`: Modified to perform actual DB lookups inside `AuthService.GetProfile` mapping all new records, including `avatar_url`.
2. `PUT /api/v1/auth/me`: Invokes `AuthService.UpdateProfile` calling the new `UserRepository.Update(User)` logic.
