package router

import (
	"free-api-news/internal/config"
	"free-api-news/internal/handler"
	"free-api-news/internal/middleware"
	"net/http"

	httpSwagger "github.com/swaggo/http-swagger/v2"
)

func New(
	authHandler  *handler.AuthHandler,
	newsHandler  *handler.NewsHandler,
	adminHandler *handler.AdminHandler,
	jwtCfg *config.JWTConfig,
) http.Handler {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"ok","service":"free-api-news"}`))
	})

	// Swagger Docs
	mux.HandleFunc("GET /swagger/", httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"),
	))

	authMid  := middleware.Auth(jwtCfg)
	adminMid := middleware.AdminOnly

	// ── Auth (public) ─────────────────────────────────────────────────────────
	mux.HandleFunc("POST /api/v1/auth/register", authHandler.Register)
	mux.HandleFunc("POST /api/v1/auth/login",    authHandler.Login)
	mux.HandleFunc("POST /api/v1/auth/refresh",  authHandler.RefreshToken)

	// ── Auth (protected) ──────────────────────────────────────────────────────
	mux.Handle("POST /api/v1/auth/logout", authMid(http.HandlerFunc(authHandler.Logout)))
	mux.Handle("GET /api/v1/auth/me",      authMid(http.HandlerFunc(authHandler.Me)))

	// ── News (public) ─────────────────────────────────────────────────────────
	mux.HandleFunc("GET /api/v1/news/categories",   newsHandler.GetCategories)
	mux.HandleFunc("GET /api/v1/news",              newsHandler.GetFeed)
	mux.HandleFunc("GET /api/v1/news/{slug}",       newsHandler.GetArticle)

	// ── Admin (JWT + admin role required) ─────────────────────────────────────
	mux.Handle("POST /api/v1/admin/articles",
		authMid(adminMid(http.HandlerFunc(adminHandler.CreateArticle))),
	)

	// Apply global middleware (CORS → Logger → mux)
	return middleware.CORS(middleware.Logger(mux))
}
