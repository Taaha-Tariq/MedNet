import pool from '../db/pool.js';

// Health data table stores various metric types for each user
// type: heartRate | bloodPressure | temperature | bloodSugar
export async function initHealthSchema() {
  await pool.query('CREATE EXTENSION IF NOT EXISTS pgcrypto;');
  await pool.query(`
    CREATE TABLE IF NOT EXISTS health_data (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL,
      type TEXT NOT NULL,
      value DOUBLE PRECISION NOT NULL,
      unit TEXT,
      timestamp TIMESTAMPTZ NOT NULL,
      additional_data JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_health_user_type_time ON health_data(user_id, type, timestamp DESC);
  `);
}

export async function insertHealth({ userId, type, value, unit, timestamp, additionalData }) {
  const { rows } = await pool.query(
    `INSERT INTO health_data (user_id, type, value, unit, timestamp, additional_data)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, user_id AS "userId", type, value, unit, timestamp`,
    [userId, type, value, unit || null, timestamp, additionalData ? JSON.stringify(additionalData) : null]
  );
  return rows[0];
}

export async function latestByTypes(userId) {
  const types = ['heartRate', 'bloodPressure', 'temperature', 'bloodSugar'];
  const results = [];
  for (const t of types) {
    const { rows } = await pool.query(
      `SELECT id, user_id AS "userId", type, value, unit, timestamp
       FROM health_data WHERE user_id = $1 AND type = $2
       ORDER BY timestamp DESC LIMIT 1`,
      [userId, t]
    );
    if (rows[0]) results.push(rows[0]);
  }
  return results;
}

export async function listByType(userId, type, limit = 10, offset = 0) {
  const { rows } = await pool.query(
    `SELECT id, user_id AS "userId", type, value, unit, timestamp, additional_data AS "additionalData"
     FROM health_data WHERE user_id = $1 AND type = $2
     ORDER BY timestamp DESC LIMIT $3 OFFSET $4`,
    [userId, type, limit, offset]
  );
  const { rows: countRows } = await pool.query(
    `SELECT COUNT(*)::int AS total FROM health_data WHERE user_id = $1 AND type = $2`,
    [userId, type]
  );
  return { data: rows, total: countRows[0].total, limit, offset };
}

export async function history(userId, { type, startDate, endDate }) {
  const where = ['user_id = $1'];
  const params = [userId];
  let i = 2;
  if (type) { where.push(`type = $${i++}`); params.push(type); }
  if (startDate) { where.push(`timestamp >= $${i++}`); params.push(startDate); }
  if (endDate) { where.push(`timestamp <= $${i++}`); params.push(endDate); }
  const sql = `SELECT id, user_id AS "userId", type, value, unit, timestamp FROM health_data WHERE ${where.join(' AND ')} ORDER BY timestamp DESC`;
  const { rows } = await pool.query(sql, params);
  return { data: rows };
}