package models

import (
	"time"
)

type User struct {
	ID           int       `db:"user_id" json:"id"`
	GovernmentID string    `db:"government_id" json:"government_id"`
	FirstName    string    `db:"first_name" json:"first_name"`
	LastName     string    `db:"last_name" json:"last_name"`
	Email        string    `db:"email" json:"email"`
	PhoneNumber  string    `db:"phone_number" json:"phone_number"`
	PasswordHash string    `db:"password_hash" json:"password"`
	CreatedAt    time.Time `db:"created_at" json:"created_at"`
	UpdatedAt    time.Time `db:"updated_at" json:"updated_at"`
}

type UserRole struct {
	ID     int    `db:"role_id" json:"id"`
	UserID int    `db:"user_id" json:"user_id"`
	Role   string `db:"role" json:"role"`
}
