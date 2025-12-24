import pool from './pool.js';
import { initHealthSchema } from '../services/health.service.js';

export async function ensureSchema() {
  const client = await pool.connect();
  try {
    // Ensure pgcrypto is available for UUID generation
    await client.query('CREATE EXTENSION IF NOT EXISTS pgcrypto;');

    // Create users table if missing
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        age INTEGER,
        profile_image_url TEXT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    // Add optional profile columns (idempotent)
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS blood_group TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS gender TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS height DOUBLE PRECISION;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS weight DOUBLE PRECISION;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS allergies TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS medications TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS medical_conditions TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS emergency_contact_name TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS emergency_contact_phone TEXT;`);
    await client.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS emergency_contact_relation TEXT;`);

    // Ensure health_data table exists and references users
    await initHealthSchema();
    console.log('DB schema ensured (users, health_data).');
  } finally {
    client.release();
  }
}
