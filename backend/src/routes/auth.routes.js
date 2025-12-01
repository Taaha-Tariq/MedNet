import { Router } from 'express';
import validate from '../middleware/validate.js';
import { signupSchema, loginSchema } from '../validators/authSchemas.js';
import { signup, login } from '../controllers/auth.controller.js';

const router = Router();

router.post('/signup', validate(signupSchema), signup);
router.post('/login', validate(loginSchema), login);

export default router;