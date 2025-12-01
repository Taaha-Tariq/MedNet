// Health Controller
// - Exposes endpoints to submit and retrieve health data
// - Supports multiple metric types and flexible history filters
import { latestByTypes, listByType, history, insertHealth } from '../services/health.service.js';

// Map alternative type spellings to canonical values used in DB/API
function normalizeType(t) {
  const map = {
    heart_rate: 'heartRate',
    blood_pressure: 'bloodPressure',
    blood_sugar: 'bloodSugar',
    sugar: 'bloodSugar',
  };
  return map[t] || t;
}

export async function getCurrent(req, res, next) {
  try {
    const latest = await latestByTypes(req.user.id);
    // If we have all metrics, return compact format; otherwise return array per spec
    const byType = Object.fromEntries(latest.map(d => [d.type, d]));
    if (byType.heartRate && byType.bloodPressure && byType.temperature && byType.bloodSugar) {
      return res.status(200).json({
        heartRate: byType.heartRate.value,
        bloodPressure: byType.bloodPressure.value,
        temperature: byType.temperature.value,
        bloodSugar: byType.bloodSugar.value,
      });
    }
    return res.status(200).json({ data: latest });
  } catch (err) {
    next(err);
  }
}

export async function getByType(req, res, next) {
  try {
    const type = normalizeType(req.params.type);
    const limit = Number(req.query.limit ?? 10);
    const offset = Number(req.query.offset ?? 0);
    const result = await listByType(req.user.id, type, limit, offset);
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function getHistory(req, res, next) {
  try {
    const type = req.query.type ? normalizeType(req.query.type) : undefined;
    const result = await history(req.user.id, {
      type,
      startDate: req.query.startDate,
      endDate: req.query.endDate,
    });
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
}

export async function submitHealth(req, res, next) {
  try {
    const body = req.validatedBody;
    const saved = await insertHealth({
      userId: req.user.id,
      type: normalizeType(body.type),
      value: body.value,
      unit: body.unit,
      timestamp: body.timestamp,
      additionalData: body.additionalData,
    });
    return res.status(201).json(saved);
  } catch (err) {
    next(err);
  }
}