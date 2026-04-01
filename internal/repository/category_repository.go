package repository

import (
	"context"
	"database/sql"
	"errors"
	"free-api-news/internal/domain"
	"time"
)

type categoryRepository struct {
	db *sql.DB
}

func NewCategoryRepository(db *sql.DB) domain.CategoryRepository {
	return &categoryRepository{db: db}
}

func (r *categoryRepository) FindAll(ctx context.Context) ([]*domain.Category, error) {
	query := `
		SELECT id, name, slug, is_active, created_at, updated_at
		FROM categories
		WHERE is_active = TRUE
		ORDER BY name ASC
	`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var categories []*domain.Category
	for rows.Next() {
		c := &domain.Category{}
		if err := rows.Scan(&c.ID, &c.Name, &c.Slug, &c.IsActive, &c.CreatedAt, &c.UpdatedAt); err != nil {
			return nil, err
		}
		categories = append(categories, c)
	}
	return categories, rows.Err()
}

func (r *categoryRepository) FindBySlug(ctx context.Context, slug string) (*domain.Category, error) {
	query := `SELECT id, name, slug, is_active, created_at, updated_at FROM categories WHERE slug = $1`
	c := &domain.Category{}
	err := r.db.QueryRowContext(ctx, query, slug).Scan(
		&c.ID, &c.Name, &c.Slug, &c.IsActive, &c.CreatedAt, &c.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return c, nil
}

func (r *categoryRepository) Create(ctx context.Context, c *domain.Category) (*domain.Category, error) {
	query := `
		INSERT INTO categories (name, slug, is_active, created_at, updated_at)
		VALUES ($1, $2, TRUE, $3, $3)
		RETURNING id, name, slug, is_active, created_at, updated_at
	`
	now := time.Now()
	result := &domain.Category{}
	err := r.db.QueryRowContext(ctx, query, c.Name, c.Slug, now).Scan(
		&result.ID, &result.Name, &result.Slug, &result.IsActive, &result.CreatedAt, &result.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return result, nil
}
