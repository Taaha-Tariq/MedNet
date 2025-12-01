import jwt from 'jsonwebtoken';

export default function authMiddleware(req, res, next) {
  const header = req.headers['authorization'] || '';
  const parts = header.split(' ');
  const token = parts.length === 2 && parts[0] === 'Bearer' ? parts[1] : null;
  if (!token) return res.status(401).json({ message: 'Unauthorized' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: payload.sub };
    next();
  } catch (e) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
}