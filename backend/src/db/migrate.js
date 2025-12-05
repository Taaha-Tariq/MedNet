import fs from 'fs';
import path from 'path';
import pool from './pool.js';
import { initHealthSchema } from '../services/health.service.js';

async function migrate() {
  const sqlPath = path.join(process.cwd(), 'src', 'db', 'migrate.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  const client = await pool.connect();
  try {
    await client.query(sql);
    await initHealthSchema();
    console.log('Migration complete');
  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});