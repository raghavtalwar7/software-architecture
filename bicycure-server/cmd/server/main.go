package main

import (
	"bicycure-server/internal/config"
	"bicycure-server/internal/database"
	"bicycure-server/internal/services"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

// Required environment variables
const (
	EnvDatabaseURL = "DATABASE_URL"
	EnvJWTSecret   = "JWT_SECRET"
	EnvPort        = "PORT"
)

// validateEnvVars checks if all required environment variables are present
func validateEnvVars() error {
	required := []string{EnvDatabaseURL, EnvJWTSecret, EnvPort}
	for _, env := range required {
		if os.Getenv(env) == "" {
			return fmt.Errorf("required environment variable %s is not set", env)
		}
	}
	return nil
}

// main is the entry point for the server
// It initializes configuration, database connection, and services
// Then starts the HTTP server with configured routes
func main() {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file: ", err)
	}

	// Validate required environment variables
	if err := validateEnvVars(); err != nil {
		log.Fatal("Environment validation failed: ", err)
	}

	// Initialize configuration
	cfg := config.New()

	// Initialize database connection
	db, err := database.NewDatabase(cfg.DatabaseURL)
	if err != nil {
		log.Fatal("Failed to connect to database: ", err)
	}
	defer db.Close()

	// Initialize services with database connection
	bicycleService := services.NewBicycleService(db)
	theftReportService := services.NewTheftReportService(db)
	userService := services.NewUserService(db)

	// Setup routes and start server
	router := SetupRoutes(bicycleService, theftReportService, userService)

	log.Printf("Server starting on port %s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, router); err != nil {
		log.Fatal("Server failed to start: ", err)
	}
}
