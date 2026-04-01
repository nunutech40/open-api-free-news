package repository

import (
	"context"
	"database/sql"
	"errors"
	"free-api-news/internal/domain"
	"time"
)

type tokenRepository struct {
	db *sql.DB
}

func NewTokenRepository(db *sql.DB) domain.TokenRepository {
	return &tokenRepository{db: db}
}

func (r *tokenRepository) Save(ctx context.Context, token *domain.Token) (*domain.Token, error) {
	query := `
		INSERT INTO tokens (user_id, access_token, refresh_token, access_expiry, refresh_expiry, is_revoked, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, user_id, access_token, refresh_token, access_expiry, refresh_expiry, is_revoked, created_at
	`
	result := &domain.Token{}
	err := r.db.QueryRowContext(ctx, query,
		token.UserID,
		token.AccessToken,
		token.RefreshToken,
		token.AccessExpiry,
		token.RefreshExpiry,
		false,
		time.Now(),
	).Scan(
		&result.ID,
		&result.UserID,
		&result.AccessToken,
		&result.RefreshToken,
		&result.AccessExpiry,
		&result.RefreshExpiry,
		&result.IsRevoked,
		&result.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *tokenRepository) FindByRefreshToken(ctx context.Context, refreshToken string) (*domain.Token, error) {
	query := `
		SELECT id, user_id, access_token, refresh_token, access_expiry, refresh_expiry, is_revoked, created_at
		FROM tokens
		WHERE refresh_token = $1
	`
	token := &domain.Token{}
	err := r.db.QueryRowContext(ctx, query, refreshToken).Scan(
		&token.ID,
		&token.UserID,
		&token.AccessToken,
		&token.RefreshToken,
		&token.AccessExpiry,
		&token.RefreshExpiry,
		&token.IsRevoked,
		&token.CreatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return token, nil
}

func (r *tokenRepository) RevokeByUserID(ctx context.Context, userID int64) error {
	_, err := r.db.ExecContext(ctx,
		`UPDATE tokens SET is_revoked = true WHERE user_id = $1 AND is_revoked = false`,
		userID,
	)
	return err
}

func (r *tokenRepository) RevokeByRefreshToken(ctx context.Context, refreshToken string) error {
	_, err := r.db.ExecContext(ctx,
		`UPDATE tokens SET is_revoked = true WHERE refresh_token = $1`,
		refreshToken,
	)
	return err
}

func (r *tokenRepository) DeleteExpired(ctx context.Context) error {
	_, err := r.db.ExecContext(ctx,
		`DELETE FROM tokens WHERE refresh_expiry < NOW()`,
	)
	return err
}
