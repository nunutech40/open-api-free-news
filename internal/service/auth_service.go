package service

import (
	"context"
	"errors"
	"free-api-news/internal/config"
	"free-api-news/internal/domain"
	"free-api-news/internal/util"
	"time"
)

type authService struct {
	userRepo  domain.UserRepository
	tokenRepo domain.TokenRepository
	jwtCfg    *config.JWTConfig
}

func NewAuthService(
	userRepo domain.UserRepository,
	tokenRepo domain.TokenRepository,
	jwtCfg *config.JWTConfig,
) domain.AuthService {
	return &authService{
		userRepo:  userRepo,
		tokenRepo: tokenRepo,
		jwtCfg:    jwtCfg,
	}
}

func (s *authService) Register(ctx context.Context, req *domain.RegisterRequest) (*domain.AuthResponse, error) {
	// Check duplicate email
	existing, err := s.userRepo.FindByEmail(ctx, req.Email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("email already registered")
	}

	// Hash password
	hashed, err := util.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	// Persist user
	user, err := s.userRepo.Create(ctx, &domain.User{
		Name:     req.Name,
		Email:    req.Email,
		Password: hashed,
	})
	if err != nil {
		return nil, err
	}

	return s.issueTokens(ctx, user)
}

func (s *authService) Login(ctx context.Context, req *domain.LoginRequest) (*domain.AuthResponse, error) {
	user, err := s.userRepo.FindByEmail(ctx, req.Email)
	if err != nil {
		return nil, err
	}
	if user == nil || !util.CheckPassword(req.Password, user.Password) {
		return nil, errors.New("invalid email or password")
	}

	return s.issueTokens(ctx, user)
}

func (s *authService) Logout(ctx context.Context, refreshToken string) error {
	return s.tokenRepo.RevokeByRefreshToken(ctx, refreshToken)
}

func (s *authService) RefreshToken(ctx context.Context, req *domain.RefreshRequest) (*domain.AuthResponse, error) {
	token, err := s.tokenRepo.FindByRefreshToken(ctx, req.RefreshToken)
	if err != nil {
		return nil, err
	}
	if token == nil {
		return nil, errors.New("refresh token not found")
	}
	if token.IsRevoked {
		return nil, errors.New("refresh token has been revoked")
	}
	if time.Now().After(token.RefreshExpiry) {
		return nil, errors.New("refresh token expired")
	}

	// Revoke old token
	if err := s.tokenRepo.RevokeByRefreshToken(ctx, req.RefreshToken); err != nil {
		return nil, err
	}

	// Load user
	user, err := s.userRepo.FindByID(ctx, token.UserID)
	if err != nil || user == nil {
		return nil, errors.New("user not found")
	}

	return s.issueTokens(ctx, user)
}

// issueTokens generates a new token pair and persists it
func (s *authService) issueTokens(ctx context.Context, user *domain.User) (*domain.AuthResponse, error) {
	pair, err := util.GenerateTokenPair(user.ID, user.Email, user.Role, s.jwtCfg)
	if err != nil {
		return nil, err
	}

	_, err = s.tokenRepo.Save(ctx, &domain.Token{
		UserID:        user.ID,
		AccessToken:   pair.AccessToken,
		RefreshToken:  pair.RefreshToken,
		AccessExpiry:  pair.AccessExpiry,
		RefreshExpiry: pair.RefreshExpiry,
	})
	if err != nil {
		return nil, err
	}

	return &domain.AuthResponse{
		User:         user,
		AccessToken:  pair.AccessToken,
		RefreshToken: pair.RefreshToken,
		AccessExpiry: pair.AccessExpiry,
	}, nil
}
