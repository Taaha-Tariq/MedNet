/*
  Auth Controller
  - Handles signup and login flows
  - Uses bcrypt for password hashing and JWT for authentication
  - Returns responses matching the mobile app's expected format
*/
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createUser, findUserByEmail, toPublicUser } from '../services/user.service.js';

export async function signup(req, res, next) {
  try {
    const { fullName, email, password, age } = req.validatedBody;
    const existing = await findUserByEmail(email);
    if (existing) return res.status(400).json({ message: 'Email already in use' });
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await createUser({ fullName, email, passwordHash, age });
    const token = jwt.sign({}, process.env.JWT_SECRET, { subject: user.id, expiresIn: '7d' });
    return res.status(201).json({ token, user: toPublicUser(user) });
  } catch (err) {
    next(err);
  }
}

export async function login(req, res, next) {
  try {
    const { email, password } = req.validatedBody;
    const user = await findUserByEmail(email);
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ message: 'Invalid credentials' });
    const token = jwt.sign({}, process.env.JWT_SECRET, { subject: user.id, expiresIn: '7d' });
    return res.status(200).json({ token, user: toPublicUser(user) });
  } catch (err) {
    next(err);
  }
}