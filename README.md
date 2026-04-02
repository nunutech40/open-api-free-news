# free-api-news 📰

Backend REST API for a Flutter News App — built with **Go** + **PostgreSQL**.

## Features

- ✅ Register with bcrypt password hashing
- ✅ Login → returns JWT access token + opaque refresh token
- ✅ Logout → revokes refresh token
- ✅ Refresh token rotation (old token revoked on rotation)
- ✅ Token expiry (access: 15m, refresh: 7d by default)
- ✅ Protected `/me` endpoint
- ✅ CORS & request logger middleware
- ✅ Graceful shutdown

---

## Project Structure

```
free-api-news/
├── cmd/api/main.go          # Entrypoint
├── internal/
│   ├── config/              # Env config loader
│   ├── database/            # PostgreSQL connection
│   ├── domain/              # Entities + interfaces
│   ├── repository/          # DB layer (users, tokens)
│   ├── service/             # Business logic
│   ├── handler/             # HTTP handlers
│   ├── middleware/           # Auth, Logger, CORS
│   ├── router/              # Route registration
│   └── util/                # JWT, bcrypt, response helpers
├── migrations/              # SQL migration files
├── deploy/                  # Systemd service file
├── Makefile
└── .env.example
```

---

## Quick Start

### 1. Prerequisites

- Go 1.22+
- PostgreSQL running locally

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your DB credentials and a strong JWT_SECRET
```

### 3. Create Database & Run Migrations

```bash
createdb free_api_news
# Run all migrations in order
for f in migrations/*.sql; do
    psql -U postgres -d free_api_news -f "$f"
done
```

### 4. Run

```bash
make run
# or: go run ./cmd/api/main.go
```

---

## API Endpoints

| Method | Path                           | Auth Required   | Description                   |
|--------|--------------------------------|-----------------|-------------------------------|
| GET    | `/swagger/index.html`          | No              | Swagger UI API Docs           |
| GET    | `/health`                      | No              | Health check                  |
| POST   | `/api/v1/auth/register`        | No              | Register new user             |
| POST   | `/api/v1/auth/login`           | No              | Login                         |
| POST   | `/api/v1/auth/logout`          | ✅ Bearer       | Logout                        |
| POST   | `/api/v1/auth/refresh`         | No              | Refresh token pair            |
| GET    | `/api/v1/auth/me`              | ✅ Bearer       | Get current user              |
| PUT    | `/api/v1/auth/me`              | ✅ Bearer       | Update current user profile   |
| POST   | `/api/v1/upload`               | ✅ Bearer       | Upload an image file (multipart/form-data)    |
| GET    | `/api/v1/news/categories`      | ✅ Bearer       | List news categories          |
| GET    | `/api/v1/news`                 | ✅ Bearer       | Get news feed with pagination |
| GET    | `/api/v1/news/{slug}`          | ✅ Bearer       | Get full article detail       |
| POST   | `/api/v1/admin/articles`       | ✅ Bearer+Admin | Create a new article          |

### Register

```bash
curl -X POST http://103.181.143.73:8081/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com","password":"secret123"}'
```

### Login

```bash
curl -X POST http://103.181.143.73:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"secret123"}'
```

### Refresh Token

```bash
curl -X POST http://103.181.143.73:8081/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<your-refresh-token>"}'
```

### Protected Route

```bash
curl http://103.181.143.73:8081/api/v1/auth/me \
  -H "Authorization: Bearer <access_token>"
```

---

## Token Strategy

| Token        | Type        | Storage     | Expiry  | Notes                           |
|-------------|-------------|-------------|---------|----------------------------------|
| access_token | JWT (HS256) | Memory/Prefs| 15 min  | Stateless, validated on each req |
| refresh_token| Opaque UUID | Secure DB   | 7 days  | Rotated on every refresh call    |

**Rotation**: Every call to `/refresh` revokes the old refresh token and issues a new pair.

---

## Deploy to VPS

VPS: `nunuadmin@103.181.143.73`

```bash
# 1. Build Linux binary + copy files to VPS
make deploy

# 2. Run DB migrations on VPS (first time)
make deploy-migrate

# 3. Watch logs
make logs

# 4. Check status
make status
```

> **Note**: Make sure `/home/nunuadmin/apps/free-api-news/.env` exists on the VPS with production values before starting the service.

---

## Environment Variables

| Variable           | Default           | Description                  |
|--------------------|-------------------|------------------------------|
| `APP_PORT`         | `8081`            | HTTP port                    |
| `APP_ENV`          | `development`     | Environment label            |
| `DB_HOST`          | `localhost`       | PostgreSQL host              |
| `DB_PORT`          | `5432`            | PostgreSQL port              |
| `DB_USER`          | `postgres`        | DB user                      |
| `DB_PASSWORD`      | ` `              | DB password                  |
| `DB_NAME`          | `free_api_news`   | Database name                |
| `DB_SSLMODE`       | `disable`         | SSL mode                     |
| `JWT_SECRET`       | *(required)*      | HS256 signing secret         |
| `JWT_ACCESS_EXPIRY`| `15m`             | Access token TTL             |
| `JWT_REFRESH_EXPIRY`| `168h`           | Refresh token TTL (7 days)   |
