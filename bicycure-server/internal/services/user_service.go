package services

import (
	"bicycure-server/internal/database"
	"bicycure-server/internal/models"
	"bicycure-server/pkg/auth"
	"database/sql"
	"errors"
	"fmt"
	"golang.org/x/crypto/bcrypt"
)

type UserService struct {
	db *database.Database
}

func NewUserService(db *database.Database) *UserService {
	return &UserService{db: db}
}

func (s *UserService) RegisterUser(user *models.User) (*models.User, error) {
	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.PasswordHash), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	query := `
        INSERT INTO users (government_id, first_name, last_name, email, phone_number, password_hash)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING user_id, created_at, updated_at
    `
	err = s.db.QueryRow(
		query,
		user.GovernmentID,
		user.FirstName,
		user.LastName,
		user.Email,
		user.PhoneNumber,
		string(hashedPassword),
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return nil, err
	}

	// Clear the password hash before returning
	user.PasswordHash = ""

	return user, nil
}

//func (s *UserService) GetUser(id int) (*models.User, error) {
//	query := `SELECT user_id,email,first_name,last_name,phone_number,created_at,updated_at FROM users WHERE user_id = $1`
//	user := &models.User{}
//	err := s.db.QueryRow(query, id).Scan(&user.ID, &user.Email, &user.FirstName, &user.LastName, &user.PhoneNumber, &user.CreatedAt, &user.UpdatedAt)
//	if err != nil {
//		return nil, err
//	}
//
//	return user, nil
//}

//func (s *UserService) UpdateUser(user *models.User) (*models.User, error) {
//	query := `
//        UPDATE users
//        SET government_id = $1, first_name = $2, last_name = $3, email = $4,
//            phone_number = $5, updated_at = $6
//        WHERE user_id = $7
//        RETURNING user_id, government_id, first_name, last_name, email, phone_number,
//                  created_at, updated_at
//    `
//	updatedUser := &models.User{}
//	err := s.db.QueryRow(query,
//		user.GovernmentID,
//		user.FirstName,
//		user.LastName,
//		user.Email,
//		user.PhoneNumber,
//		time.Now(),
//		user.ID,
//	).Scan(
//		&updatedUser.ID,
//		&updatedUser.GovernmentID,
//		&updatedUser.FirstName,
//		&updatedUser.LastName,
//		&updatedUser.Email,
//		&updatedUser.PhoneNumber,
//		&updatedUser.CreatedAt,
//		&updatedUser.UpdatedAt,
//	)
//	if err != nil {
//		return nil, err
//	}
//
//	return updatedUser, nil
//}

func (s *UserService) Login(email, password string) (string, error) {
	user := &models.User{}
	query := `SELECT user_id, password_hash FROM users WHERE email = $1`
	err := s.db.QueryRow(query, email).Scan(&user.ID, &user.PasswordHash)
	if err != nil {
		fmt.Println(err)
		if errors.Is(err, sql.ErrNoRows) {
			return "", errors.New("user not found")
		}
		return "", err
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	// Generate JWT token
	token, err := auth.GenerateToken(user.ID)
	if err != nil {
		return "", err
	}

	return token, nil
}
