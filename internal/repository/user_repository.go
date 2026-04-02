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
	query := `
		INSERT INTO users (name, email, password, role, created_at, updated_at)
		VALUES ($1, $2, $3, 'user', $4, $4)
		RETURNING id, name, email, role, created_at, updated_at
	`
	now := time.Now()
	result := &domain.User{}
	err := r.db.QueryRowContext(ctx, query,
		user.Name, user.Email, user.Password, now,
	).Scan(&result.ID, &result.Name, &result.Email, &result.Role, &result.CreatedAt, &result.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return result, nil
}

func (r *userRepository) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	query := `SELECT id, name, email, password, role, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE email = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, email).Scan(
		&user.ID, &user.Name, &user.Email, &user.Password, &user.Role,
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
	query := `SELECT id, name, email, role, avatar_url, bio, phone, preferences, created_at, updated_at FROM users WHERE id = $1`
	user := &domain.User{}
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&user.ID, &user.Name, &user.Email, &user.Role,
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


