## About

BiCycure is a mobile application designed to modernize bicycle ownership, security, and recovery. It offers a seamless solution for cyclists to verify/transfer ownership and facilitate quick recovery through a combination of law enforcement and community assistance.

BiCycure is developed using Golang for the backend, PostgreSQL for the database and Flutter for the frontend.

The aims of this PoC are to highlight the implementations of specific features in order to enhance the desired quality attributes mentioned in our first report. The user experience is an essential part of BiCycure, as each operation needs to be as smooth as possible in order to ensure wide scale adoption. To achieve this, strong usability testing is needed.

<img src="Images/poc.mp4" alt="Poc Working" width="300" height="400">

## Installation

1. Ensure you have Golang installed on your system.
2. Clone this repository.
3. Run `go mod tidy` to download the required dependencies.
4. Create a `.env` file in the `BiCycure-server` directory. It should have three keys:
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

## App Installation

### Prerequisites

Before running the app, ensure you have the following installed on your machine:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0 or above)
- [Dart](https://dart.dev/get-dart)
- A suitable IDE (e.g., [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))

### Getting Started

#### 1. Clone the Repository

Clone the repository to your local machine using the following command:

1. git clone https://github.com/your-username/BiCycure.git
2. cd BiCycure
3. flutter pub get
4. NOTE- It is recommended to run the app in a physical device as it has features which only run in physical devices like scanning RFID.
5. Select your device. (Either physical or virtual device [Emulator])
6. Run main.dart file the app will get built and then installed on your device.
7. Add a .env file in the root of the folder. Add the following code API_BASE_URL=http://IPv4_Address:PORT_NUMBER. This will be picked up for api's to work.
   (NOTE: IPv4 address can be found by typing the following command in cmd: ipconfig and the coppy the IPv4 address of connection you are connected to.)

## Connection with architectural decision

Our choice of Monolithic Architecture (MA) for this Proof of Concept (PoC) complements the quality attributes of the system.
The system is not reliant on a multitude of dependencies (which would hinder the development process). This is a highly desirable quality since if the application doesn't serve the current needs of the user base, it can serve as a foundation for future improvements and/or be partially refactored into other architectural patterns (such as microservices or P2P) without requiring a complete recreation from the ground up.

We also believe that the use of MA will assist in evaluating the usability of our PoC. By quickly building a functional prototype, we can gather early feedback on the user experience, as a monolithic design allows for the quick creation of a working version where all components (backend, database and frontend) are tightly connected. This enables immediate interaction testing, allowing users to experience the app as intended and helping us identify any issues in the user flow. Additionally, it allows us to test complete use cases, such as registering a bike and transfering ownership, all within a consistent environment. With this setup, we can pinpoint usability bottlenecks by observing how users engage with the app and where they encounter difficulties, allowing us to make relevant adjustments that improve the overall experience, and also identify and fix bugs quickly. This approach provides critical insights into how well the PoC aligns with user needs and helps guide future design changes.

While we acknowledge that MAs often struggle to provide the necessary scalability that we outlined in our first report, there is a number of techniques that can be used to address any issues that might arise as the system's user base grows. While their implementation is not within the scope of this PoC, we present some of them here:

- Horizontal Scaling and use of load balancers to distribute the increasing workload.
- Optimizing database queries using indexing and caching, given the large portion of read operations that are bound to take place.
- Transitioning certain performance intensive system functions into microservice based architecture.

## Usability Testing

The purpose of these usability tests is to see whether the user has a pleasant and easy interaction with the system where it is most essential. Our usability tests look at the three specific use cases which are essential to our system.

Usability tests automatically fail if the system doesn't technically work, if this is the case it is noted. A real bicycle is used with a unique tag attached at the seat post.

### Test subject instructions and questions

We define exactly what instructions test subjects are given before each of their three tasks.

**Instructions before test**:
_"In the future we envision that bicycles will have digital tags that can be scanned which identify a bicycle uniquely. Tags are always embedded in the seat post of the bicycle. BiCycure is a tool that allows bicycle owners to register their bicycle to their name, such that in case of theft the bicycle can be returned to the rightful owner. In this test you will try to use BiCycure to complete a few tasks."_

**Test Questions Asked After Each Task:**

1. _On a scale from 1 (unpleasant) to 5 (pleasant), how do you feel about the overall experience of the task?_
2. _What can we improve, either in this step or in the experience in general?_

Additionally, after tasks 1 and 2 the user is asked:

- If you had BiCycure already installed on your own phone, would you take the steps you just did?\*

The test subject does not know that there is a limit in time. The timer only serves as a purpose to not have a test subject be stuck on a task they can't complete. If the timer runs out we simply continue to the next task. Whether or not a task is completed is noted.

### User registers a new bicycle (max 2 min.)

**Instructions:**
_"You recently bought a new bicycle. You want to now register it in the BiCycure app."_
![Figure: RFID Chip First Scan (=user has new bicycle)](../../Images/scenarios/sc2.png)

### User reports a theft (max 2 min.)

**Instructions:**
_"Your bicycle was stolen. You want to report your theft to the BiCycure database."_
![Figure: Declaring Bicycle Theft (=users bicycle is stolen)](../../Images/scenarios/sc3.png)

### User checks an unknown bicycle (max 1 min.)

**Instructions:**
_"You want to check whether this bicycle has been stolen."_
![Figure: Scanning an Unknown Bicycle (=users checks if bike is stolen)](../../Images/scenarios/sc5.png)

## Results

All three use-cases identified as most important to the system are implemented and functioning reliably on a technical level. Usability tests were done to evaluate the how new users interact with the system. Four test subjects were used in the usability tests:

### Test Subject 1

| Task                                                                                    | Rating                  | Would Use? | Improvement Suggestions                                                                                                                                                                                                     |
| --------------------------------------------------------------------------------------- | ----------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Register New Bicycle**<br>_Task: Register newly purchased bicycle in BiCycure app_ | 4/5<br>(Quite Pleasant) | Yes        | • Location of frame tag unclear<br>• "Little I" issue mentioned, can use some help or information text                                                                                                                      |
| **2. Report Theft**<br>_Task: Report stolen bicycle to BiCycure database_               | 3/5<br>(Neutral)        | Yes        | • Date format errors only shown after submission - need immediate validation or rejection<br>• Unclear description requirements (bicycle/theft/location?)<br>• Need better indication of mandatory fields (stars suggested) |
| **3. Check Unknown Bicycle**<br>_Task: Verify if a bicycle is stolen_                   | 5/5<br>(Pleasant)       | N/A        | • Improve scan success indication<br>• UI clarity needs improvement                                                                                                                                                         |

### Test Subject 2

| Task                                                                                    | Rating                  | Would Use? | Improvement Suggestions                                                                                                  |
| --------------------------------------------------------------------------------------- | ----------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------ |
| **1. Register New Bicycle**<br>_Task: Register newly purchased bicycle in BiCycure app_ | 3/5<br>(Neutral)        | Yes        | Many steps have to be taken in order to register my bicycle, I want it faster as I don't just want to use my new bicycle |
| **2. Report Theft**<br>_Task: Report stolen bicycle to BiCycure database_               | 4/5<br>(Quite Pleasant) | Yes        | The date field format was trial and error. For the rest perfect                                                          |
| **3. Check Unknown Bicycle**<br>_Task: Verify if a bicycle is stolen_                   | 5/5<br>(Pleasant)       | N/A        | No problems here                                                                                                         |

# API Documentation

## Users API

### Register User

Creates a new user account.

**Endpoint:** `POST /users`

**Request Body:**

```json
{
  "government_id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "phone_number": "string",
  "password": "string"
}
```

**Response:**

- Status: `201 Created`
- Content-Type: `application/json`

```json
{
  "id": "integer",
  "government_id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "phone_number": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid request body or validation error
- `409 Conflict`: Email already registered
- `500 Internal Server Error`: Server-side error

### Login

Authenticates a user and returns a JWT token.

**Endpoint:** `POST /login`

**Request Body:**

```json
{
  "email": "string",
  "password": "string"
}
```

**Response:**

- Status: `200 OK`
- Content-Type: `application/json`

```json
{
  "token": "string"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid request body or missing required fields
- `401 Unauthorized`: Invalid email or password
- `500 Internal Server Error`: Authentication failed

## Authentication

All protected endpoints require a valid JWT token obtained through the login endpoint. The token should be included in the Authorization header of subsequent requests:

```
Authorization: Bearer <token>
```

## Data Models

### User

```json
{
  "id": "integer",
  "government_id": "string",
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "phone_number": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Notes

- All timestamps are returned in ISO 8601 format
- The password is never returned in responses
- Email addresses must be unique across all users

## Theft Reports API

### Overview

The Theft Reports API allows users to create, retrieve, and update bicycle theft reports. All endpoints require authentication using JWT.

### Base URL

```
/theft-reports
```

### Create Theft Report

Creates a new theft report for a bicycle.

**Endpoint:** `POST /theft-reports`

**Request Body:**

```json
{
  "bicycle_id": 123,
  "theft_date": "2024-03-15",
  "theft_location": "123 Main St, City",
  "description": "Bike was stolen from outside the grocery store",
  "reward_amount": 100.0
}
```

**Required Fields:**

- `bicycle_id` (integer): ID of the stolen bicycle
- `theft_date` (string): Date of theft in YYYY-MM-DD format
- `theft_location` (string): Location where the theft occurred
- `description` (string): Description of the theft incident
- `reward_amount` (number): Reward amount for recovering the bicycle

**Response:** `201 Created`

```json
{
  "id": 456,
  "bicycle_id": 123,
  "reporter_id": 789,
  "theft_date": "2024-03-15",
  "theft_location": "123 Main St, City",
  "description": "Bike was stolen from outside the grocery store",
  "reward_amount": 100.0,
  "status_id": 1,
  "created_at": "2024-03-15T14:30:00Z",
  "updated_at": "2024-03-15T14:30:00Z"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid request body or validation error
- `404 Not Found`: Specified bicycle not found
- `401 Unauthorized`: Missing or invalid authentication
- `500 Internal Server Error`: Server-side error

### Get Theft Report

Retrieves a specific theft report by ID.

**Endpoint:** `GET /theft-reports/{id}`

**URL Parameters:**

- `id` (integer): The ID of the theft report to retrieve

**Response:** `200 OK`

```json
{
  "id": 456,
  "bicycle_id": 123,
  "reporter_id": 789,
  "theft_date": "2024-03-15",
  "theft_location": "123 Main St, City",
  "description": "Bike was stolen from outside the grocery store",
  "reward_amount": 100.0,
  "status_id": 1,
  "created_at": "2024-03-15T14:30:00Z",
  "updated_at": "2024-03-15T14:30:00Z"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid report ID format
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Not authorized to view this report
- `404 Not Found`: Report not found
- `500 Internal Server Error`: Server-side error

### Update Theft Report

Updates an existing theft report.

**Endpoint:** `PUT /theft-reports/{id}`

**URL Parameters:**

- `id` (integer): The ID of the theft report to update

**Request Body:**

```json
{
  "bicycle_id": 123,
  "theft_date": "2024-03-15",
  "theft_location": "Updated location details",
  "description": "Updated description of the theft",
  "reward_amount": 150.0,
  "status_id": 2
}
```

**Response:** `200 OK`

```json
{
  "id": 456,
  "bicycle_id": 123,
  "reporter_id": 789,
  "theft_date": "2024-03-15",
  "theft_location": "Updated location details",
  "description": "Updated description of the theft",
  "reward_amount": 150.0,
  "status_id": 2,
  "created_at": "2024-03-15T14:30:00Z",
  "updated_at": "2024-03-15T15:45:00Z"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid request body or validation error
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Not authorized to update this report
- `404 Not Found`: Report not found
- `500 Internal Server Error`: Server-side error

## Date Formats

- All dates in requests should be provided in `YYYY-MM-DD` format
- All dates in responses are provided in two formats:
  - `theft_date`: ISO 8601 format in the JSON response
  - `theft_date_str`: YYYY-MM-DD format for display purposes

## Notes

- Only the original reporter can update a theft report
- Creating a theft report automatically updates the bicycle's status to 'stolen'

## Bicycle API

### Authentication

All bicycle endpoints require a valid JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Endpoints

### Register Bicycle

Registers a new bicycle for the authenticated user.

- **URL**: `/bicycles`
- **Method**: `POST`
- **Auth Required**: Yes
- **Request Body**:
  ```json
  {
    "rfid_tag": "string",
    "brand": "string",
    "model": "string",
    "color": "string",
    "frame_number": "string"
  }
  ```
- **Success Response**: `201 Created`
  ```json
  {
    "id": 1,
    "rfid_tag": "ABC123",
    "brand": "Trek",
    "model": "FX3",
    "color": "Blue",
    "frame_number": "TK123456",
    "current_owner_id": 1,
    "status": "active",
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  }
  ```
- **Error Responses**:
  - `400 Bad Request`: Invalid request body
  - `401 Unauthorized`: Invalid or missing token
  - `409 Conflict`: Duplicate RFID tag

### List User's Bicycles

Retrieves all bicycles owned by the authenticated user.

- **URL**: `/bicycles/list`
- **Method**: `GET`
- **Auth Required**: Yes
- **Success Response**: `200 OK`
  ```json
  [
    {
      "id": 1,
      "rfid_tag": "ABC123",
      "brand": "Trek",
      "model": "FX3",
      "color": "Blue",
      "frame_number": "TK123456",
      "current_owner_id": 1,
      "status": "active",
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:00:00Z"
    }
  ]
  ```
- **Success Response (No Bicycles)**: `204 No Content`
- **Error Response**:
  - `401 Unauthorized`: Invalid or missing token
  - `500 Internal Server Error`: Server processing error

### Scan Bicycle

Scans a bicycle's RFID tag and returns its status. If the bicycle is marked as stolen, returns the owner's contact information.

- **URL**: `/bicycles/scan`
- **Method**: `POST`
- **Auth Required**: Yes
- **Request Body**:
  ```json
  {
    "rfid": "ABC123",
    "place": "Central Park",
    "city": "New York",
    "pincode": "10024"
  }
  ```
- **Success Response (Not Stolen)**: `200 OK`
  ```json
  {
    "status": "Not Stolen"
  }
  ```
- **Success Response (Stolen)**: `200 OK`
  ```json
  {
    "status": "Stolen",
    "owner_name": "John Doe",
    "owner_email": "john.doe@example.com"
  }
  ```
- **Error Responses**:
  - `400 Bad Request`: Invalid request body or missing RFID
  - `401 Unauthorized`: Invalid or missing token
  - `404 Not Found`: Bicycle not found
  - `500 Internal Server Error`: Failed to process scan

## Data Models

### Bicycle

```json
{
  "id": "integer",
  "rfid_tag": "string",
  "brand": "string",
  "model": "string",
  "color": "string",
  "frame_number": "string",
  "current_owner_id": "integer",
  "status": "string",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### Bicycle Scan

```json
{
  "id": "integer",
  "bicycle_id": "integer",
  "user_id": "integer",
  "scan_date": "timestamp",
  "place": "string",
  "pincode": "string",
  "city": "string"
}
```

## Status Codes

- `200`: Success
- `201`: Created
- `204`: No Content (Empty result)
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error
