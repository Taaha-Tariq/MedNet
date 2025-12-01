import { Router } from 'express';
import auth from '../middleware/auth.js';
import validate from '../middleware/validate.js';
import { submitHealthSchema } from '../validators/healthSchemas.js';
import { getCurrent, getByType, getHistory, submitHealth } from '../controllers/health.controller.js';

const router = Router();

router.get('/current', auth, getCurrent);
router.get('/:type', auth, getByType);
router.get('/history', auth, getHistory);
router.post('/submit', auth, validate(submitHealthSchema), submitHealth);

export default router;