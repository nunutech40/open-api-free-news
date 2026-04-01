package domain

import "time"

// Category is the news category domain entity
type Category struct {
	ID          int64     `json:"id"`
	Name        string    `json:"name"`
	Slug        string    `json:"slug"`
	Description string    `json:"description"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Article is the news article domain entity
type Article struct {
	ID              int64      `json:"id"`
	CategoryID      int64      `json:"category_id"`
	CategoryName    string     `json:"category_name"`
	AuthorID        int64      `json:"author_id"`
	AuthorName      string     `json:"author_name"`
	Title           string     `json:"title"`
	Slug            string     `json:"slug"`
	Excerpt         string     `json:"excerpt"`
	Content         string     `json:"content,omitempty"` // omitted in list, included in detail
	ImageURL        string     `json:"image_url"`
	ThumbnailURL    string     `json:"thumbnail_url,omitempty"`
	ReadTimeMinutes int        `json:"read_time_minutes"`
	Status          string     `json:"status"`
	PublishedAt     *time.Time `json:"published_at"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// NewsFeedResponse is the structured response for the Flutter Hero+Grid UI
type NewsFeedResponse struct {
	HeroArticle  *Article        `json:"hero_article"`
	FeedArticles []*Article      `json:"feed_articles"`
	Meta         *PaginationMeta `json:"meta"`
}

// PaginationMeta holds pagination info for list responses
type PaginationMeta struct {
	CurrentPage int   `json:"current_page"`
	TotalPages  int   `json:"total_pages"`
	TotalItems  int64 `json:"total_items"`
	Limit       int   `json:"limit"`
}

// NewsFeedQuery holds filter parameters for the news feed endpoint
type NewsFeedQuery struct {
	Category    string // category slug, empty = all categories
	Page        int    // defaults to 1
	Limit       int    // defaults to 10, max 50
	IncludeHero bool   // if true, first article is separated as hero_article
}

// CreateArticleRequest is the admin input to create a new article
type CreateArticleRequest struct {
	CategoryID   int64  `json:"category_id"`
	Title        string `json:"title"`
	Excerpt      string `json:"excerpt"`
	Content      string `json:"content"`
	ImageURL     string `json:"image_url"`
	ThumbnailURL string `json:"thumbnail_url"`
	Status       string `json:"status"` // "draft" or "published"
}
