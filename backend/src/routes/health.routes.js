import { Router } from 'express';
import auth from '../middleware/auth.js';
import validate, { validateParams, validateQuery } from '../middleware/validate.js';
import { submitHealthSchema, typeParamSchema, paginationSchema, historyQuerySchema } from '../validators/healthSchemas.js';
import { getCurrent, getByType, getHistory, submitHealth } from '../controllers/health.controller.js';

const router = Router();

router.get('/current', auth, getCurrent);
router.get('/history', auth, validateQuery(historyQuerySchema), getHistory);
router.get('/:type', auth, validateParams(typeParamSchema), validateQuery(paginationSchema), getByType);
router.post('/submit', auth, validate(submitHealthSchema), submitHealth);

export default router;