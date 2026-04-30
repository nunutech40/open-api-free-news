package repository

import (
	"context"
	"database/sql"
	"errors"
	"free-api-news/internal/domain"
	"time"
)

type userRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) domain.UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *domain.User) (*domain.User, error) {
	if user.AuthProvider == "" {
		user.AuthProvider = "local"
	}
	
	query := `
		INSERT INTO users (name, email, password, auth_provider, google_id, role, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, 'user', $6, $6)
		RETURNING id, name, email, role, auth_provider, google_id, created_at, updated_at
	`
	now := time.Now()
	result := &domain.User{}
	err := r.db.QueryRowContext(ctx, query,
		user.Name, user.Email, user.Password, user.AuthProvider, user.GoogleID, now,
	).Scan(&result.ID, &result.Name, &result.Email, &result.Role, &result.AuthProvider, &result.GoogleID, &result.CreatedAt, &result.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *userRepository) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `SELECT id, name, email, password, role, auth_provider, google_id, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE email = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, email).Scan(
		&user.ID, &user.Name, &user.Email, &user.Password, &user.Role,
		&user.AuthProvider, &user.GoogleID,
		&user.AvatarURL, &user.Bio, &user.Phone, &user.Preferences,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *userRepository) FindByID(ctx context.Context, id int64) (*domain.User, error) {
	query := `SELECT id, name, email, role, auth_provider, google_id, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE id = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role,
		&user.AuthProvider, &user.GoogleID,
		&user.AvatarURL, &user.Bio, &user.Phone, &user.Preferences,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *userRepository) FindByGoogleID(ctx context.Context, googleID string) (*domain.User, error) {
	query := `SELECT id, name, email, role, auth_provider, google_id, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE google_id = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, googleID).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role,
		&user.AuthProvider, &user.GoogleID,
		&user.AvatarURL, &user.Bio, &user.Phone, &user.Preferences,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *userRepository) LinkGoogleID(ctx context.Context, userID int64, googleID string) error {
	query := `UPDATE users SET google_id = $1, updated_at = $2 WHERE id = $3`
	_, err := r.db.ExecContext(ctx, query, googleID, time.Now(), userID)
	return err
}

func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users 
		SET name = $1, avatar_url = $2, bio = $3, phone = $4, preferences = $5, updated_at = $6
		WHERE id = $7
	`
	_, err := r.db.ExecContext(ctx, query,
		user.Name, user.AvatarURL, user.Bio, user.Phone, user.Preferences, time.Now(), user.ID,
	)
	return err
}

func (r *userRepository) FindByPhone(ctx context.Context, phone string) (*domain.User, error) {
	query := `SELECT id, name, email, role, auth_provider, google_id, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE phone = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, phone).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role,
		&user.AuthProvider, &user.GoogleID,
		&user.AvatarURL, &user.Bio, &user.Phone, &user.Preferences,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *userRepository) UpdatePasswordByPhone(ctx context.Context, phone, hashedPassword string) error {
	query := `UPDATE users SET password = $1, updated_at = $2 WHERE phone = $3`
	result, err := r.db.ExecContext(ctx, query, hashedPassword, time.Now(), phone)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

