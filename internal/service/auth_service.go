package service

import (
	"context"
	"errors"
	"free-api-news/internal/config"
	"free-api-news/internal/domain"
	"free-api-news/internal/util"
	"time"

	"firebase.google.com/go/v4/auth"
)

type authService struct {
	userRepo  domain.UserRepository
	tokenRepo domain.TokenRepository
	jwtCfg    *config.JWTConfig
	appCfg    *config.AppConfig
	fbAuth    *auth.Client
}

func NewAuthService(
	userRepo domain.UserRepository,
	tokenRepo domain.TokenRepository,
	jwtCfg *config.JWTConfig,
	appCfg *config.AppConfig,
	fbAuth *auth.Client,
) domain.AuthService {
	return &authService{
		userRepo:  userRepo,
		tokenRepo: tokenRepo,
		jwtCfg:    jwtCfg,
		appCfg:    appCfg,
		fbAuth:    fbAuth,
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
		Password: &hashed,
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
	if user == nil {
		return nil, errors.New("invalid email or password")
	}

	if user.Password == nil {
		return nil, errors.New("invalid email or password")
	}

	if !util.CheckPassword(req.Password, *user.Password) {
		return nil, errors.New("invalid email or password")
	}

	return s.issueTokens(ctx, user)
}

func (s *authService) Logout(ctx context.Context, refreshToken string) error {
	return s.tokenRepo.RevokeByRefreshToken(ctx, refreshToken)
}

func (s *authService) OAuthLogin(ctx context.Context, req *domain.OAuthLoginRequest) (*domain.AuthResponse, error) {
	// 1. Verify the unified Firebase ID Token
	if s.fbAuth == nil {
		return nil, errors.New("firebase auth is not initialized on the server")
	}

	token, err := s.fbAuth.VerifyIDToken(ctx, req.IDToken)
	if err != nil {
		return nil, errors.New("invalid or expired firebase token: " + err.Error())
	}

	// 2. Extract standard claims from Firebase token
	firebaseUID := token.UID
	email, ok := token.Claims["email"].(string)
	if !ok || email == "" {
		// Some providers (like Twitter/GitHub) might not provide an email if the user hides it.
		// However, Firebase Auth usually handles this gracefully depending on console settings.
		return nil, errors.New("email not found in firebase token claims")
	}
	
	name, _ := token.Claims["name"].(string)
	if name == "" {
		name = "Firebase User"
	}

	// 3. Find user by Firebase UID
	user, err := s.userRepo.FindByFirebaseUID(ctx, firebaseUID)
	if err != nil {
		return nil, err
	}

	if user == nil {
		// Fallback: check if a user with this email already exists
		userByEmail, err := s.userRepo.FindByEmail(ctx, email)
		if err != nil {
			return nil, err
		}

		if userByEmail != nil {
			// Account linking: User exists with this email, so just link the FirebaseUID
			if err := s.userRepo.LinkFirebaseUID(ctx, userByEmail.ID, firebaseUID); err != nil {
				return nil, err
			}
			user = userByEmail
			user.FirebaseUID = &firebaseUID
		} else {
			// Create brand new user
			newUser := &domain.User{
				Name:         name,
				Email:        email,
				AuthProvider: req.Provider, // "google", "github", "twitter"
				FirebaseUID:  &firebaseUID,
			}
			
			createdUser, err := s.userRepo.Create(ctx, newUser)
			if err != nil {
				return nil, err
			}
			user = createdUser
		}
	}

	// 4. Issue Backend API Tokens
	return s.issueTokens(ctx, user)
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

func (s *authService) GetProfile(ctx context.Context, userID int64) (*domain.User, error) {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}
	return user, nil
}

func (s *authService) UpdateProfile(ctx context.Context, userID int64, req *domain.UpdateProfileRequest) (*domain.User, error) {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	user.Name = req.Name
	user.AvatarURL = req.AvatarURL
	user.Bio = req.Bio
	user.Phone = req.Phone
	if req.Preferences != "" {
		user.Preferences = req.Preferences
	}

	err = s.userRepo.Update(ctx, user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (s *authService) ResetPasswordForgot(ctx context.Context, req *domain.ForgotPasswordRequest) error {
	// 1. Verify Firebase ID Token
	if s.fbAuth == nil {
		return errors.New("firebase auth is not initialized on the server")
	}

	token, err := s.fbAuth.VerifyIDToken(ctx, req.FirebaseIDToken)
	if err != nil {
		return errors.New("invalid or expired firebase token: " + err.Error())
	}

	// 2. Extract phone number
	phoneInfo, ok := token.Claims["phone_number"]
	if !ok {
		return errors.New("firebase token does not contain a verified phone number")
	}
	phone := phoneInfo.(string)

	// 3. Find user by phone
	user, err := s.userRepo.FindByPhone(ctx, phone)
	if err != nil {
		return err
	}
	if user == nil {
		return errors.New("user with this phone number not found")
	}

	// 4. Hash new password
	hashed, err := util.HashPassword(req.NewPassword)
	if err != nil {
		return err
	}

	// 5. Update DB
	err = s.userRepo.UpdatePasswordByPhone(ctx, phone, hashed)
	if err != nil {
		return err
	}

	// 6. Security: Revoke all existing sessions so the user has to login with the new password
	_ = s.tokenRepo.RevokeByUserID(ctx, user.ID)

	return nil
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
