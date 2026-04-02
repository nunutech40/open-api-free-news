package domain

import "context"

// UserRepository defines data access for users
type UserRepository interface {
	Create(ctx context.Context, user *User) (*User, error)
	FindByEmail(ctx context.Context, email string) (*User, error)
	FindByID(ctx context.Context, id int64) (*User, error)
	Update(ctx context.Context, user *User) error
}

// TokenRepository defines data access for tokens
type TokenRepository interface {
	Save(ctx context.Context, token *Token) (*Token, error)
	FindByRefreshToken(ctx context.Context, refreshToken string) (*Token, error)
	RevokeByUserID(ctx context.Context, userID int64) error
	RevokeByRefreshToken(ctx context.Context, refreshToken string) error
	DeleteExpired(ctx context.Context) error
}

// AuthService defines auth business logic
type AuthService interface {
	Register(ctx context.Context, req *RegisterRequest) (*AuthResponse, error)
	Login(ctx context.Context, req *LoginRequest) (*AuthResponse, error)
	Logout(ctx context.Context, refreshToken string) error
	RefreshToken(ctx context.Context, req *RefreshRequest) (*AuthResponse, error)
	GetProfile(ctx context.Context, userID int64) (*User, error)
	UpdateProfile(ctx context.Context, userID int64, req *UpdateProfileRequest) (*User, error)
}

// CategoryRepository defines data access for news categories
type CategoryRepository interface {
	FindAll(ctx context.Context) ([]*Category, error)
	FindBySlug(ctx context.Context, slug string) (*Category, error)
	Create(ctx context.Context, c *Category) (*Category, error)
}

// ArticleRepository defines data access for news articles
type ArticleRepository interface {
	FindFeed(ctx context.Context, query *NewsFeedQuery) ([]*Article, int64, error)
	FindBySlug(ctx context.Context, slug string) (*Article, error)
	Create(ctx context.Context, a *Article) (*Article, error)
	Update(ctx context.Context, a *Article) (*Article, error)
}

// NewsService defines news business logic
type NewsService interface {
	GetCategories(ctx context.Context) ([]*Category, error)
	GetFeed(ctx context.Context, query *NewsFeedQuery) (*NewsFeedResponse, error)
	GetArticleBySlug(ctx context.Context, slug string) (*Article, error)
	CreateArticle(ctx context.Context, authorID int64, req *CreateArticleRequest) (*Article, error)
}
