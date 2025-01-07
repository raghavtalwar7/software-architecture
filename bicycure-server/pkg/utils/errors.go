package utils

import "errors"

// Common service errors
var (
	// Authentication and authorization errors
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrUnauthorized       = errors.New("user is not authorized to perform this action")

	// Resource errors
	ErrBicycleNotFound = errors.New("bicycle not found")
	ErrReportNotFound  = errors.New("theft report not found")
	ErrUserNotFound    = errors.New("user not found")

	// Validation errors
	ErrValidation     = errors.New("validation failed")
	ErrDuplicateEmail = errors.New("email already exists")
	ErrDuplicate      = errors.New("resource already exists")

	// Input validation errors
	ErrInvalidRFID        = errors.New("invalid RFID tag")
	ErrInvalidBicycleData = errors.New("invalid bicycle data")
	ErrInvalidUserData    = errors.New("invalid user data")
	ErrInvalidReportData  = errors.New("invalid report data")

	// Business logic errors
	ErrBicycleAlreadyRegistered = errors.New("bicycle is already registered")
	ErrBicycleAlreadyReported   = errors.New("bicycle is already reported as stolen")
	ErrInvalidBicycleStatus     = errors.New("invalid bicycle status")
)

// ValidationError represents a detailed validation error
type ValidationError struct {
	Field   string
	Message string
}

// ValidationErrors is a collection of validation errors
type ValidationErrors []ValidationError

// Error implements the error interface for ValidationErrors
func (ve ValidationErrors) Error() string {
	if len(ve) == 0 {
		return "no validation errors"
	}

	// Return first validation error as the error message
	return ve[0].Message
}

// NewValidationError creates a new validation error for a specific field
func NewValidationError(field, message string) ValidationError {
	return ValidationError{
		Field:   field,
		Message: message,
	}
}

// IsNotFoundError checks if the error is a "not found" error
func IsNotFoundError(err error) bool {
	return errors.Is(err, ErrBicycleNotFound) ||
		errors.Is(err, ErrReportNotFound) ||
		errors.Is(err, ErrUserNotFound)
}

// IsValidationError checks if the error is a validation error
func IsValidationError(err error) bool {
	return errors.Is(err, ErrValidation) ||
		errors.Is(err, ErrInvalidRFID) ||
		errors.Is(err, ErrInvalidBicycleData) ||
		errors.Is(err, ErrInvalidUserData) ||
		errors.Is(err, ErrInvalidReportData)
}

// IsDuplicateError checks if the error is a duplicate resource error
func IsDuplicateError(err error) bool {
	return errors.Is(err, ErrDuplicate) ||
		errors.Is(err, ErrDuplicateEmail) ||
		errors.Is(err, ErrBicycleAlreadyRegistered) ||
		errors.Is(err, ErrBicycleAlreadyReported)
}
