package config

import "os"

type Config struct {
	DatabaseURL string
	Port        string
	JWTSecret   string
}

func New() *Config {
	return &Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		Port:        os.Getenv("PORT"),
		JWTSecret:   os.Getenv("JWT_SECRET"),
	}
}
