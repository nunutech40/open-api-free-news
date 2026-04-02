package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"free-api-news/internal/domain"
	"time"
)

type articleRepository struct {
	db *sql.DB
}

func NewArticleRepository(db *sql.DB) domain.ArticleRepository {
	return &articleRepository{db: db}
}

// FindFeed returns a paginated list of published articles, optionally filtered by category slug.
func (r *articleRepository) FindFeed(ctx context.Context, query *domain.NewsFeedQuery) ([]*domain.Article, int64, error) {
	if query.Page < 1 {
		query.Page = 1
	}
	if query.Limit < 1 || query.Limit > 50 {
		query.Limit = 10
	}
	offset := (query.Page - 1) * query.Limit

	// Base where clause — only show published articles
	where := "a.status = 'published'"
	args := []interface{}{}
	argIdx := 1

	if query.Category != "" {
		where += fmt.Sprintf(" AND c.slug = $%d", argIdx)
		args = append(args, query.Category)
		argIdx++
	}

	if query.Search != "" {
		where += fmt.Sprintf(" AND (a.title ILIKE $%d OR a.content ILIKE $%d)", argIdx, argIdx)
		searchPattern := "%" + query.Search + "%"
		args = append(args, searchPattern)
		argIdx++
	}

	// Count total items
	countQuery := fmt.Sprintf(`
		SELECT COUNT(*) FROM articles a
		JOIN categories c ON a.category_id = c.id
		WHERE %s
	`, where)
	var total int64
	if err := r.db.QueryRowContext(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// Fetch articles (no content field for list view — performance)
	args = append(args, query.Limit, offset)
	dataQuery := fmt.Sprintf(`
		SELECT
			a.id, a.category_id, c.name AS category_name,
			a.author_id, u.name AS author_name,
			a.title, a.slug, COALESCE(a.excerpt, '') AS excerpt,
			COALESCE(a.image_url, '') AS image_url,
			COALESCE(a.thumbnail_url, '') AS thumbnail_url,
			a.read_time_minutes, a.status,
			a.published_at, a.created_at, a.updated_at
		FROM articles a
		JOIN categories c ON a.category_id = c.id
		JOIN users u      ON a.author_id    = u.id
		WHERE %s
		ORDER BY a.published_at DESC
		LIMIT $%d OFFSET $%d
	`, where, argIdx, argIdx+1)

	rows, err := r.db.QueryContext(ctx, dataQuery, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var articles []*domain.Article
	for rows.Next() {
		a := &domain.Article{}
		if err := rows.Scan(
			&a.ID, &a.CategoryID, &a.CategoryName,
			&a.AuthorID, &a.AuthorName,
			&a.Title, &a.Slug, &a.Description,
			&a.ImageURL, &a.ThumbnailURL,
			&a.ReadTimeMinutes, &a.Status,
			&a.PublishedAt, &a.CreatedAt, &a.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		articles = append(articles, a)
	}
	return articles, total, rows.Err()
}

// FindBySlug returns a single published article including its full content.
func (r *articleRepository) FindBySlug(ctx context.Context, slug string) (*domain.Article, error) {
	query := `
		SELECT
			a.id, a.category_id, c.name AS category_name,
			a.author_id, u.name AS author_name,
			a.title, a.slug, COALESCE(a.excerpt, ''),
			a.content,
			COALESCE(a.image_url, ''), COALESCE(a.thumbnail_url, ''),
			a.read_time_minutes, a.status,
			a.published_at, a.created_at, a.updated_at
		FROM articles a
		JOIN categories c ON a.category_id = c.id
		JOIN users u      ON a.author_id    = u.id
		WHERE a.slug = $1 AND a.status = 'published'
	`
	a := &domain.Article{}
	err := r.db.QueryRowContext(ctx, query, slug).Scan(
		&a.ID, &a.CategoryID, &a.CategoryName,
		&a.AuthorID, &a.AuthorName,
		&a.Title, &a.Slug, &a.Description,
		&a.Content,
		&a.ImageURL, &a.ThumbnailURL,
		&a.ReadTimeMinutes, &a.Status,
		&a.PublishedAt, &a.CreatedAt, &a.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return a, nil
}

// Create persists a new article and returns the saved entity.
func (r *articleRepository) Create(ctx context.Context, a *domain.Article) (*domain.Article, error) {
	query := `
		INSERT INTO articles
			(category_id, author_id, title, slug, excerpt, content, image_url, thumbnail_url,
			 read_time_minutes, status, published_at, created_at, updated_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$12)
		RETURNING id, created_at, updated_at
	`
	now := time.Now()
	err := r.db.QueryRowContext(ctx, query,
		a.CategoryID, a.AuthorID, a.Title, a.Slug, a.Description, a.Content,
		a.ImageURL, a.ThumbnailURL, a.ReadTimeMinutes, a.Status, a.PublishedAt, now,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return a, nil
}

// Update updates an existing article.
func (r *articleRepository) Update(ctx context.Context, a *domain.Article) (*domain.Article, error) {
	query := `
		UPDATE articles SET
			category_id=$1, title=$2, slug=$3, excerpt=$4, content=$5,
			image_url=$6, thumbnail_url=$7, read_time_minutes=$8,
			status=$9, published_at=$10, updated_at=$11
		WHERE id=$12
		RETURNING updated_at
	`
	now := time.Now()
	err := r.db.QueryRowContext(ctx, query,
		a.CategoryID, a.Title, a.Slug, a.Description, a.Content,
		a.ImageURL, a.ThumbnailURL, a.ReadTimeMinutes,
		a.Status, a.PublishedAt, now, a.ID,
	).Scan(&a.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return a, nil
}
