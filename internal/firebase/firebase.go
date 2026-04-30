package firebase

import (
	"context"
	"log"
	"os"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"google.golang.org/api/option"
)

// InitAuth initializes the Firebase Admin Auth Client
func InitAuth(ctx context.Context) (*auth.Client, error) {
	credPath := os.Getenv("FIREBASE_CREDENTIALS")

	var app *firebase.App
	var err error

	if credPath != "" {
		// Use explicit credential file
		opt := option.WithCredentialsFile(credPath)
		app, err = firebase.NewApp(ctx, nil, opt)
	} else {
		// Implicitly use GOOGLE_APPLICATION_CREDENTIALS or default credentials
		app, err = firebase.NewApp(ctx, nil)
	}

	if err != nil {
		return nil, err
	}

	client, err := app.Auth(ctx)
	if err != nil {
		return nil, err
	}

	log.Println("✅ Firebase Auth Admin SDK initialized")
	return client, nil
}
