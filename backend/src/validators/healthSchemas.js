import Joi from 'joi';

const typeValues = ['heartRate', 'bloodPressure', 'temperature', 'bloodSugar'];

export const submitHealthSchema = Joi.object({
  type: Joi.string().valid(...typeValues, 'heart_rate', 'blood_pressure', 'blood_sugar', 'sugar').required(),
  value: Joi.number().required(),
  unit: Joi.string().allow('', null),
  timestamp: Joi.string().isoDate().required(),
  additionalData: Joi.object().unknown(true).optional(),
});

export const typeParamSchema = Joi.object({
  type: Joi.string().valid(...typeValues).required(),
});

export const paginationSchema = Joi.object({
  limit: Joi.number().integer().min(1).max(100).default(10),
  offset: Joi.number().integer().min(0).default(0),
});

export const historyQuerySchema = Joi.object({
  type: Joi.string().valid(...typeValues).optional(),
  startDate: Joi.string().isoDate().optional(),
  endDate: Joi.string().isoDate().optional(),
});