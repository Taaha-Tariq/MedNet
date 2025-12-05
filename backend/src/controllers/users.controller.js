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
    const allowed = [
      'fullName', 'email', 'age', 'profileImageUrl',
      'bloodGroup', 'gender', 'height', 'weight', 'phoneNumber', 'dateOfBirth',
      'allergies', 'medications', 'medicalConditions',
      'emergencyContactName', 'emergencyContactPhone', 'emergencyContactRelation'
    ];
    const updates = {};
    for (const k of allowed) if (fields[k] !== undefined) updates[k] = fields[k];
    const sets = [];
    const values = [];
    let i = 1;
    if (updates.fullName) { sets.push(`full_name = $${i++}`); values.push(updates.fullName); }
    if (updates.email) { sets.push(`email = $${i++}`); values.push(updates.email); }
    if (updates.age !== undefined) { sets.push(`age = $${i++}`); values.push(updates.age); }
    if (updates.profileImageUrl !== undefined) { sets.push(`profile_image_url = $${i++}`); values.push(updates.profileImageUrl); }
    if (updates.bloodGroup !== undefined) { sets.push(`blood_group = $${i++}`); values.push(updates.bloodGroup); }
    if (updates.gender !== undefined) { sets.push(`gender = $${i++}`); values.push(updates.gender); }
    if (updates.height !== undefined) { sets.push(`height = $${i++}`); values.push(updates.height); }
    if (updates.weight !== undefined) { sets.push(`weight = $${i++}`); values.push(updates.weight); }
    if (updates.phoneNumber !== undefined) { sets.push(`phone_number = $${i++}`); values.push(updates.phoneNumber); }
    if (updates.dateOfBirth !== undefined) { sets.push(`date_of_birth = $${i++}`); values.push(updates.dateOfBirth ? new Date(updates.dateOfBirth) : null); }
    if (updates.allergies !== undefined) { sets.push(`allergies = $${i++}`); values.push(updates.allergies); }
    if (updates.medications !== undefined) { sets.push(`medications = $${i++}`); values.push(updates.medications); }
    if (updates.medicalConditions !== undefined) { sets.push(`medical_conditions = $${i++}`); values.push(updates.medicalConditions); }
    if (updates.emergencyContactName !== undefined) { sets.push(`emergency_contact_name = $${i++}`); values.push(updates.emergencyContactName); }
    if (updates.emergencyContactPhone !== undefined) { sets.push(`emergency_contact_phone = $${i++}`); values.push(updates.emergencyContactPhone); }
    if (updates.emergencyContactRelation !== undefined) { sets.push(`emergency_contact_relation = $${i++}`); values.push(updates.emergencyContactRelation); }
    if (sets.length === 0) {
      const me = await findUserById(req.user.id);
      return res.status(200).json(toPublicUser(me));
    }
    sets.push(`updated_at = NOW()`);
    values.push(req.user.id);
    const query = `UPDATE users SET ${sets.join(', ')} WHERE id = $${i}
                   RETURNING id, full_name, email, age, profile_image_url,
                             blood_group, gender, height, weight, phone_number, date_of_birth,
                             allergies, medications, medical_conditions,
                             emergency_contact_name, emergency_contact_phone, emergency_contact_relation`;
    const { rows } = await (await import('../db/pool.js')).default.query(query, values);
    return res.status(200).json(toPublicUser(rows[0]));
  } catch (err) {
    next(err);
  }
}