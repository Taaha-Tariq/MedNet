# MedNet Backend Commands

These commands help you set up, migrate, run, and smoke-test the backend locally.

## Prerequisites
- PostgreSQL running locally and reachable via `DATABASE_URL`
- Node.js 18+

## 1) Configure Environment
```bash
cd backend
cp .env.example .env
# Edit .env to set real credentials
nano .env
```

## 2) Install Dependencies
```bash
npm install
```

## 3) Create Database (if needed)
```bash
# Replace with your postgres superuser URL if different
psql "postgres://user:password@localhost:5432/postgres" -c "CREATE DATABASE mednet;" || true
```

## 4) Run Migrations
```bash
npm run migrate
```

## 5) Start the Server
```bash
npm run dev
# Server listens on PORT from .env (default 4000)
```

## 6) Smoke Tests
Replace `TOKEN` after login.

```bash
# Signup
curl -sS -X POST http://localhost:4000/api/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{ "fullName":"John Doe", "email":"john@example.com", "password":"password123", "age":25 }'

# Login
curl -sS -X POST http://localhost:4000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{ "email":"john@example.com", "password":"password123" }'

# Get Profile
curl -sS http://localhost:4000/api/users/me \
  -H "Authorization: Bearer TOKEN"

# Update Profile
curl -sS -X PUT http://localhost:4000/api/users/me \
  -H "Authorization: Bearer TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{ "fullName":"John Updated", "age":26 }'

# Submit Health Data
curl -sS -X POST http://localhost:4000/api/health/submit \
  -H "Authorization: Bearer TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{ "type":"heartRate", "value":72.0, "unit":"bpm", "timestamp":"2024-01-15T10:30:00Z", "additionalData": { "device": "Watch" } }'

# Get Current Health
curl -sS http://localhost:4000/api/health/current \
  -H "Authorization: Bearer TOKEN"

# Get Health by Type
curl -sS "http://localhost:4000/api/health/heartRate?limit=10&offset=0" \
  -H "Authorization: Bearer TOKEN"

# Get Health History
curl -sS "http://localhost:4000/api/health/history?type=heartRate&startDate=2024-01-01T00:00:00Z&endDate=2024-12-31T23:59:59Z" \
  -H "Authorization: Bearer TOKEN"
```

## Notes
- All timestamps should be ISO 8601 strings (e.g., `2024-01-15T10:30:00Z`).
- Send `Authorization: Bearer TOKEN` on all user-specific endpoints.
- Errors return `{ "message": "..." }`.