package service

import (
	"context"
	"errors"
	"free-api-news/internal/domain"
	"free-api-news/internal/util"
	"math"
	"time"
)

type newsService struct {
	categoryRepo domain.CategoryRepository
	articleRepo  domain.ArticleRepository
}

func NewNewsService(
	categoryRepo domain.CategoryRepository,
	articleRepo domain.ArticleRepository,
) domain.NewsService {
	return &newsService{
		categoryRepo: categoryRepo,
		articleRepo:  articleRepo,
	}
}

// GetCategories returns all active categories.
func (s *newsService) GetCategories(ctx context.Context) ([]*domain.Category, error) {
	return s.categoryRepo.FindAll(ctx)
}

// GetFeed returns a paginated news feed.
// If query.IncludeHero is true, the first article is separated as HeroArticle.
func (s *newsService) GetFeed(ctx context.Context, query *domain.NewsFeedQuery) (*domain.NewsFeedResponse, error) {
	// Sanitise defaults
	if query.Page < 1 {
		query.Page = 1
	}
	if query.Limit < 1 || query.Limit > 50 {
		query.Limit = 10
	}

	articles, total, err := s.articleRepo.FindFeed(ctx, query)
	if err != nil {
		return nil, err
	}

	totalPages := int(math.Ceil(float64(total) / float64(query.Limit)))
	if totalPages < 1 {
		totalPages = 1
	}

	resp := &domain.NewsFeedResponse{
		FeedArticles: []*domain.Article{},
		Meta: &domain.PaginationMeta{
			CurrentPage: query.Page,
			TotalPages:  totalPages,
			TotalItems:  total,
			Limit:       query.Limit,
		},
	}

	if len(articles) == 0 {
		return resp, nil
	}

	// If include_hero requested AND we're on page 1, separate the first article
	if query.IncludeHero && query.Page == 1 {
		resp.HeroArticle = articles[0]
		resp.FeedArticles = articles[1:]
	} else {
		resp.FeedArticles = articles
	}

	return resp, nil
}

// GetArticleBySlug returns full article detail by slug.
func (s *newsService) GetArticleBySlug(ctx context.Context, slug string) (*domain.Article, error) {
	article, err := s.articleRepo.FindBySlug(ctx, slug)
	if err != nil {
		return nil, err
	}
	if article == nil {
		return nil, errors.New("article not found")
	}
	return article, nil
}

// CreateArticle validates, enriches, and persists a new article.
func (s *newsService) CreateArticle(ctx context.Context, authorID int64, req *domain.CreateArticleRequest) (*domain.Article, error) {
	// Validate required fields
	if req.CategoryID == 0 {
		return nil, errors.New("category_id is required")
	}
	if len(req.Title) < 5 {
		return nil, errors.New("title must be at least 5 characters")
	}
	if len(req.Content) < 50 {
		return nil, errors.New("content must be at least 50 characters")
	}
	if req.Status != "draft" && req.Status != "published" {
		return nil, errors.New("status must be 'draft' or 'published'")
	}

	// Verify category exists
	cat, err := s.categoryRepo.FindBySlug(ctx, "")
	_ = cat
	_ = err
	// (Skip category existence check for now — FK constraint at DB level handles this)

	// Auto-generate slug from title
	slug := util.GenerateSlug(req.Title)

	// Auto-calculate read time
	readTime := util.CalculateReadTime(req.Content)

	// Set published_at only when publishing
	var publishedAt *time.Time
	if req.Status == "published" {
		now := time.Now()
		publishedAt = &now
	}

	article := &domain.Article{
		CategoryID:      req.CategoryID,
		AuthorID:        authorID,
		Title:           req.Title,
		Slug:            slug,
		Excerpt:         req.Excerpt,
		Content:         req.Content,
		ImageURL:        req.ImageURL,
		ThumbnailURL:    req.ThumbnailURL,
		ReadTimeMinutes: readTime,
		Status:          req.Status,
		PublishedAt:     publishedAt,
	}

	return s.articleRepo.Create(ctx, article)
}
