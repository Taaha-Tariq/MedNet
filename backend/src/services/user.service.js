import pool from '../db/pool.js';

export async function findUserByEmail(email) {
  const { rows } = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return rows[0] || null;
}

export async function findUserById(id) {
  const { rows } = await pool.query(
    `SELECT id, full_name, email, age, profile_image_url,
            blood_group, gender, height, weight, phone_number, date_of_birth,
            allergies, medications, medical_conditions,
            emergency_contact_name, emergency_contact_phone, emergency_contact_relation
     FROM users WHERE id = $1`,
    [id]
  );
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
    bloodGroup: u.blood_group ?? undefined,
    gender: u.gender ?? undefined,
    height: u.height ?? undefined,
    weight: u.weight ?? undefined,
    phoneNumber: u.phone_number ?? undefined,
    dateOfBirth: u.date_of_birth ? new Date(u.date_of_birth).toISOString() : undefined,
    allergies: u.allergies ?? undefined,
    medications: u.medications ?? undefined,
    medicalConditions: u.medical_conditions ?? undefined,
    emergencyContactName: u.emergency_contact_name ?? undefined,
    emergencyContactPhone: u.emergency_contact_phone ?? undefined,
    emergencyContactRelation: u.emergency_contact_relation ?? undefined,
  };
}