package util

import (
	"regexp"
	"strings"
)

var nonAlphaNum = regexp.MustCompile(`[^a-z0-9\s-]`)
var multiSpace   = regexp.MustCompile(`\s+`)

// GenerateSlug converts a title into a URL-safe slug.
// e.g. "Apple's AI Leap; The New iPhone 16 Pro" → "apples-ai-leap-the-new-iphone-16-pro"
func GenerateSlug(title string) string {
	s := strings.ToLower(title)
	s = nonAlphaNum.ReplaceAllString(s, "")
	s = multiSpace.ReplaceAllString(strings.TrimSpace(s), "-")
	return s
}
