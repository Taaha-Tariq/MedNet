// Users Controller
// - Provides endpoints to fetch and update your own profile
// - Keeps response keys in camelCase to match the app expectations
import { findUserById, toPublicUser } from '../services/user.service.js';

export async function getMe(req, res, next) {
  try {
    const user = await findUserById(req.user.id);
    if (!user) return res.status(404).json({ message: 'Not Found' });
    return res.status(200).json(toPublicUser(user));
  } catch (err) {
    next(err);
  }
}

export async function updateMe(req, res, next) {
  try {
    const fields = req.body || {};
    const allowed = ['fullName', 'email', 'age'];
    const updates = {};
    for (const k of allowed) if (fields[k] !== undefined) updates[k] = fields[k];
    const sets = [];
    const values = [];
    let i = 1;
    if (updates.fullName) { sets.push(`full_name = $${i++}`); values.push(updates.fullName); }
    if (updates.email) { sets.push(`email = $${i++}`); values.push(updates.email); }
    if (updates.age !== undefined) { sets.push(`age = $${i++}`); values.push(updates.age); }
    if (sets.length === 0) {
      const me = await findUserById(req.user.id);
      return res.status(200).json(toPublicUser(me));
    }
    sets.push(`updated_at = NOW()`);
    values.push(req.user.id);
    const query = `UPDATE users SET ${sets.join(', ')} WHERE id = $${i} RETURNING id, full_name, email, age`;
    const { rows } = await (await import('../db/pool.js')).default.query(query, values);
    return res.status(200).json(toPublicUser(rows[0]));
  } catch (err) {
    next(err);
  }
}