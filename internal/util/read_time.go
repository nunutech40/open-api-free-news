package util

import (
	"math"
	"strings"
)

// CalculateReadTime estimates reading time in minutes.
// Standard: 200 words per minute. Minimum 1 minute.
func CalculateReadTime(content string) int {
	words := len(strings.Fields(content))
	minutes := int(math.Ceil(float64(words) / 200.0))
	if minutes < 1 {
		return 1
	}
	return minutes
}
