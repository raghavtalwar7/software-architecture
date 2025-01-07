package main

import (
	"bicycure-server/internal/api/handlers"
	"bicycure-server/internal/api/middleware"
	"bicycure-server/internal/services"

	"github.com/gorilla/mux"
)

// SetupRoutes configures and returns the application router with all API endpoints
// It initializes handlers with their respective services and sets up protected and public routes
func SetupRoutes(
	bicycleService *services.BicycleService,
	theftReportService *services.TheftReportService,
	userService *services.UserService,
) *mux.Router {
	r := mux.NewRouter()

	// Initialize handlers
	bh := handlers.NewBicycleHandler(bicycleService)
	th := handlers.NewTheftReportHandler(theftReportService)
	uh := handlers.NewUserHandler(userService)

	// Public routes (no authentication required)
	r.HandleFunc("/users", uh.RegisterUser).Methods("POST")
	r.HandleFunc("/login", uh.Login).Methods("POST")

	// Protected bicycle routes (requires authentication)
	r.HandleFunc("/bicycles", middleware.JWTMiddleware(bh.RegisterBicycle)).Methods("POST")
	r.HandleFunc("/bicycles/scan", middleware.JWTMiddleware(bh.ScanBicycle)).Methods("POST")
	r.HandleFunc("/bicycles/list", middleware.JWTMiddleware(bh.GetUserBicycles)).Methods("GET")

	// Protected theft report routes (requires authentication)
	r.HandleFunc("/theft-reports", middleware.JWTMiddleware(th.CreateTheftReport)).Methods("POST")
	r.HandleFunc("/theft-reports/{id}", middleware.JWTMiddleware(th.GetTheftReport)).Methods("GET")
	r.HandleFunc("/theft-reports/{id}", middleware.JWTMiddleware(th.UpdateTheftReport)).Methods("PUT")

	return r
}
