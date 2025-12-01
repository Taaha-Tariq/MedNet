import pool from '../db/pool.js';

export async function findUserByEmail(email) {
  const { rows } = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return rows[0] || null;
}

export async function findUserById(id) {
  const { rows } = await pool.query('SELECT id, full_name, email, age, profile_image_url FROM users WHERE id = $1', [id]);
  return rows[0] || null;
}

export async function createUser({ fullName, email, passwordHash, age }) {
  const { rows } = await pool.query(
    'INSERT INTO users (full_name, email, password_hash, age) VALUES ($1, $2, $3, $4) RETURNING id, full_name, email, age',
    [fullName, email, passwordHash, age]
  );
  return rows[0];
}

export function toPublicUser(u) {
  if (!u) return null;
  return {
    id: u.id,
    fullName: u.full_name || u.fullName,
    email: u.email,
    age: u.age ?? null,
    profileImageUrl: u.profile_image_url ?? undefined,
  };
}