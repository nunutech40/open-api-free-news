package main

import (
	"context"
	"free-api-news/internal/config"
	"free-api-news/internal/database"
	"free-api-news/internal/handler"
	"free-api-news/internal/repository"
	"free-api-news/internal/router"
	"free-api-news/internal/service"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "free-api-news/docs" // Swagger docs
)

// @title           Free API News
// @version         1.0
// @description     Backend REST API for a Flutter News App with Auth + News Feature
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.email  support@example.com

// @license.name  MIT
// @license.url   https://opensource.org/licenses/MIT

// @host      103.181.143.73:8081
// @BasePath  /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	db, err := database.Connect(&cfg.Database)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer db.Close()

	// ── Repositories ──────────────────────────────────────────────────────────
	userRepo     := repository.NewUserRepository(db)
	tokenRepo    := repository.NewTokenRepository(db)
	categoryRepo := repository.NewCategoryRepository(db)
	articleRepo  := repository.NewArticleRepository(db)

	// ── Services ──────────────────────────────────────────────────────────────
	authSvc := service.NewAuthService(userRepo, tokenRepo, &cfg.JWT)
	newsSvc := service.NewNewsService(categoryRepo, articleRepo)

	// ── Handlers ──────────────────────────────────────────────────────────────
	authHandler  := handler.NewAuthHandler(authSvc)
	newsHandler  := handler.NewNewsHandler(newsSvc)
	adminHandler := handler.NewAdminHandler(newsSvc)

	// ── Router ────────────────────────────────────────────────────────────────
	r := router.New(authHandler, newsHandler, adminHandler, &cfg.JWT)

	srv := &http.Server{
		Addr:         ":" + cfg.App.Port,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server
	go func() {
		log.Printf("🚀 Server running on port %s (env: %s)", cfg.App.Port, cfg.App.Env)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	srv.Shutdown(ctx)
	log.Println("server stopped")
}

