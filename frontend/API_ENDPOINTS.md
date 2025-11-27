# MedNet API Endpoints Documentation

This document describes all the API endpoints that the MedNet mobile application expects from the backend.

## Base URL
```
https://your-backend-api.com/api
```

---

## Authentication Endpoints

### 1. Sign Up
- **Method**: `POST`
- **Endpoint**: `/auth/signup`
- **Headers**: 
  - `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "fullName": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "age": 25
  }
  ```
- **Success Response** (200/201):
  ```json
  {
    "token": "jwt_token_here",
    "user": {
      "id": "user_id",
      "fullName": "John Doe",
      "email": "john@example.com",
      "age": 25
    }
  }
  ```
- **Error Response** (400/500):
  ```json
  {
    "message": "Error message here"
  }
  ```

### 2. Login
- **Method**: `POST`
- **Endpoint**: `/auth/login`
- **Headers**: 
  - `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- **Success Response** (200):
  ```json
  {
    "token": "jwt_token_here",
    "user": {
      "id": "user_id",
      "fullName": "John Doe",
      "email": "john@example.com",
      "age": 25
    }
  }
  ```
- **Error Response** (401/500):
  ```json
  {
    "message": "Invalid credentials"
  }
  ```

---

## User Endpoints

### 3. Get User Profile
- **Method**: `GET`
- **Endpoint**: `/users/me`
- **Headers**: 
  - `Authorization: Bearer {token}`
  - `Content-Type: application/json`
- **Success Response** (200):
  ```json
  {
    "id": "user_id",
    "fullName": "John Doe",
    "email": "john@example.com",
    "age": 25,
    "profileImageUrl": "https://example.com/image.jpg" // optional
  }
  ```
- **Error Response** (401/500):
  ```json
  {
    "message": "Error message"
  }
  ```

### 4. Update User Profile
- **Method**: `PUT`
- **Endpoint**: `/users/me`
- **Headers**: 
  - `Authorization: Bearer {token}`
  - `Content-Type: application/json`
- **Request Body** (all fields optional):
  ```json
  {
    "fullName": "John Updated",
    "email": "johnnew@example.com",
    "age": 26
  }
  ```
- **Success Response** (200):
  ```json
  {
    "id": "user_id",
    "fullName": "John Updated",
    "email": "johnnew@example.com",
    "age": 26
  }
  ```

---

## Health Data Endpoints

### 5. Get Current Health Data
- **Method**: `GET`
- **Endpoint**: `/health/current`
- **Headers**: 
  - `Authorization: Bearer {token}`
- **Success Response** (200):
  ```json
  {
    "heartRate": 72.0,
    "bloodPressure": 120.0,
    "temperature": 36.5,
    "bloodSugar": 90.0
  }
  ```
  Or return latest readings for each type as an array:
  ```json
  {
    "data": [
      {
        "id": "health_id_1",
        "userId": "user_id",
        "type": "heartRate",
        "value": 72.0,
        "unit": "bpm",
        "timestamp": "2024-01-15T10:30:00Z"
      },
      {
        "id": "health_id_2",
        "userId": "user_id",
        "type": "bloodPressure",
        "value": 120.0,
        "unit": "mmHg",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    ]
  }
  ```

### 6. Get Health Data by Type
- **Method**: `GET`
- **Endpoint**: `/health/{type}`
  - Types: `heartRate`, `bloodPressure`, `temperature`, `bloodSugar`
- **Query Parameters**:
  - `limit`: Number of records to return (default: 10)
  - `offset`: Number of records to skip (default: 0)
- **Headers**: 
  - `Authorization: Bearer {token}`
- **Success Response** (200):
  ```json
  {
    "data": [
      {
        "id": "health_id",
        "userId": "user_id",
        "type": "heartRate",
        "value": 72.0,
        "unit": "bpm",
        "timestamp": "2024-01-15T10:30:00Z",
        "additionalData": {} // optional
      }
    ],
    "total": 50,
    "limit": 10,
    "offset": 0
  }
  ```

### 7. Get Health History/Analysis
- **Method**: `GET`
- **Endpoint**: `/health/history`
- **Query Parameters** (all optional):
  - `type`: Filter by health type (`heartRate`, `bloodPressure`, `temperature`, `bloodSugar`)
  - `startDate`: ISO 8601 date string
  - `endDate`: ISO 8601 date string
- **Headers**: 
  - `Authorization: Bearer {token}`
- **Success Response** (200):
  ```json
  {
    "data": [
      {
        "id": "health_id",
        "userId": "user_id",
        "type": "heartRate",
        "value": 72.0,
        "unit": "bpm",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    ]
  }
  ```

### 8. Submit Health Data
- **Method**: `POST`
- **Endpoint**: `/health/submit`
- **Headers**: 
  - `Authorization: Bearer {token}`
  - `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "type": "heartRate",
    "value": 72.0,
    "unit": "bpm",
    "timestamp": "2024-01-15T10:30:00Z",
    "additionalData": {
      "device": "Apple Watch",
      "notes": "After exercise"
    }
  }
  ```
- **Success Response** (200/201):
  ```json
  {
    "id": "health_id",
    "userId": "user_id",
    "type": "heartRate",
    "value": 72.0,
    "unit": "bpm",
    "timestamp": "2024-01-15T10:30:00Z"
  }
  ```

---

## Health Type Values

The `type` field in health data endpoints can be one of:
- `heartRate` (or `heart_rate`)
- `bloodPressure` (or `blood_pressure`)
- `temperature`
- `bloodSugar` (or `blood_sugar` or `sugar`)

---

## Units

- Heart Rate: `bpm` (beats per minute)
- Blood Pressure: `mmHg` (millimeters of mercury)
- Temperature: `°C` (Celsius)
- Blood Sugar: `mg/dL` (milligrams per deciliter)

---

## Error Responses

All endpoints should return consistent error responses:

```json
{
  "message": "Error description here"
}
```

Common HTTP Status Codes:
- `200`: Success
- `201`: Created (for POST requests)
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (missing or invalid token)
- `404`: Not Found
- `500`: Internal Server Error

---

## Notes

1. All timestamps should be in ISO 8601 format (e.g., `2024-01-15T10:30:00Z`)
2. JWT tokens should be included in the `Authorization` header as `Bearer {token}`
3. The backend should validate all input data
4. For pagination, use `limit` and `offset` query parameters
5. All user-specific endpoints require authentication


