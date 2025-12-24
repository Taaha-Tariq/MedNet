# MedNet Backend (Express + Postgres)

## Overview
- REST API built with Express and PostgreSQL.
- JWT auth (signup/login), input validation with Joi, CORS enabled.
- Health data endpoints accept `additionalData` (JSON) for fields like diastolic BP.

## Structure
- `index.js`: Server bootstrap (loads `src/app.js`).
- `src/app.js`: App wiring (routes, middleware).
- `src/controllers/`: Request handlers.
- `src/services/`: DB logic and business rules.
- `src/routes/`: Route definitions and wiring.
- `src/validators/`: Joi schemas (body/query/params).
- `src/middleware/`: Auth/CORS/error handlers.
- `src/db/`: Migration scripts and DB helpers.

## Setup
1. Create `.env` from example:
   - See `.env.example` for required vars:
     - `PORT=4000`
     - `DATABASE_URL=postgres://user:password@localhost:5432/mednet`
     - `JWT_SECRET=replace_with_strong_secret`
2. Install deps and run migrations:
   - `npm install`
   - `npm run migrate`
3. Start the server:
   - Dev: `npm run dev`
   - Prod: `npm start`

## Health Endpoints (quick smoke)
Assumes a running server at `http://localhost:4000`.

- Signup:
  ```bash
  curl -sS -X POST http://localhost:4000/auth/signup \
    -H 'Content-Type: application/json' \
    -d '{"email":"demo@example.com","password":"Demo123!","name":"Demo"}'
  ```
- Login (capture token):
  ```bash
  TOKEN=$(curl -sS -X POST http://localhost:4000/auth/login \
    -H 'Content-Type: application/json' \
    -d '{"email":"demo@example.com","password":"Demo123!"}' | jq -r .token)
  echo $TOKEN
  ```
- Submit BP (SYS with `additionalData.diastolic`):
  ```bash
  curl -sS -X POST http://localhost:4000/health/submit \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Content-Type: application/json' \
    -d '{
      "type":"blood_pressure",
      "value":120,
      "unit":"mmHg",
      "timestamp":"'"$(date -Is)"'",
      "additionalData": {"diastolic": 80}
    }'
  ```
- History (all types):
  ```bash
  curl -sS -H "Authorization: Bearer $TOKEN" \
    http://localhost:4000/health/history
  ```

## Notes
- Route order ensures `/health/history` is not shadowed by dynamic `/:type`.
- `additionalData` is stored as JSONB; diastolic shown in frontend Analysis.
