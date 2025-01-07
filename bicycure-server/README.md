# bicycure-server

This is the server for the BiCycure project, a system designed to tackle bicycle theft using RFID technology.

## Installation

1. Ensure you have Golang installed on your system.
2. Clone this repository.
3. Run `go mod tidy` to download the required dependencies.
4. Create a `.env` file in the `bicycure-server` directory. It should have three keys:
    - `DATABASE_URL`: the URL to your Postgres database, local or hosted.
    - `PORT`: the port on which you want this server to start.
    - `JWT_SECRET`: a secure SECRET string for signing JWTs.
5. Run the server using `go run ./cmd/server/`, and it should be up and running on the `PORT` specified in the `.env`.

### Setting up a local database
To use this server with a local Postgres instance, you can specify a `localhost` URL
in the `.env` file. To load the initial database schema, we would recommend using the [go-migrate](https://github.com/golang-migrate/migrate) tool.
You can use the following command to set up your local database:
```
 migrate -database "postgresql://postgres@localhost:5432/" -path ./scripts/migrations up
```
This will initialise your local database with the schema required to run this server.

## Project Structure

- `cmd/server/`: Contains the main application entry point.
- `internal/`: Contains the core application code.
  - `api/`: Handles HTTP requests and responses.
  - `config/`: Manages application configuration.
  - `database/`: Handles database connections and queries.
  - `models/`: Defines data structures used in the application.
  - `services/`: Implements business logic.
- `pkg/`: Contains reusable packages.
- `scripts/`: Contains database migration scripts.

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
