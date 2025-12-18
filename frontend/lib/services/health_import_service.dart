import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/health_data_model.dart';
import '../services/api_service.dart';

/// HealthImportService
///
/// Reads health records from the device using the `health` package (Health Connect on Android,
/// HealthKit on iOS) and submits them to the backend via existing `/health/submit`.
///
/// This focuses on Heart Rate, Blood Pressure, and Body Temperature.
class HealthImportService {
  final HealthFactory _health = HealthFactory(useHealthConnectIfAvailable: true);
  final ApiService _api = ApiService();

  /// Request permissions for the given types.
  Future<bool> _requestPermissionsForTypes(List<HealthDataType> types) async {
    final authorized = await _health.requestAuthorization(types, permissions: types.map((_) => HealthDataAccess.READ).toList());
    return authorized; // true if the user granted access
  }

  /// Import and submit records for a specific field mapped by `HealthType`.
  /// `daysBack` controls how far in the past to fetch.
  Future<int> importAndSubmitSelectedType({
    required HealthType type,
    required String token,
    int daysBack = 30,
  }) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: daysBack));
    int submitted = 0;

    if (type == HealthType.heartRate) {
      final types = [HealthDataType.HEART_RATE];
      if (!await _requestPermissionsForTypes(types)) return 0;
      final points = await _health.getHealthDataFromTypes(start, now, types);
      for (final p in points) {
        final value = (p.value is num) ? (p.value as num).toDouble() : double.tryParse(p.value.toString()) ?? 0.0;
        if (value <= 0) continue;
        final res = await _api.submitHealthData(
          token,
          type: HealthType.heartRate,
          value: value,
          unit: 'bpm',
          timestamp: p.dateTo,
        );
        if (res['success'] == true) submitted++;
      }
      return submitted;
    }

    if (type == HealthType.temperature) {
      final types = [HealthDataType.BODY_TEMPERATURE];
      if (!await _requestPermissionsForTypes(types)) return 0;
      final points = await _health.getHealthDataFromTypes(start, now, types);
      for (final p in points) {
        final value = (p.value is num) ? (p.value as num).toDouble() : double.tryParse(p.value.toString()) ?? 0.0;
        if (value <= 0) continue;
        final res = await _api.submitHealthData(
          token,
          type: HealthType.temperature,
          value: value,
          unit: '°C',
          timestamp: p.dateTo,
        );
        if (res['success'] == true) submitted++;
      }
      return submitted;
    }

    if (type == HealthType.bloodPressure) {
      // Fetch systolic and diastolic separately and submit as entries with systolic value
      // while attaching diastolic in additionalData for better context.
      final types = [HealthDataType.BLOOD_PRESSURE_SYSTOLIC, HealthDataType.BLOOD_PRESSURE_DIASTOLIC];
      if (!await _requestPermissionsForTypes(types)) return 0;
      final points = await _health.getHealthDataFromTypes(start, now, types);

      // Group by timestamp rounded to minute to pair values.
      Map<int, Map<HealthDataType, double>> grouped = {};
      for (final p in points) {
        final tsKey = DateTime(p.dateTo.year, p.dateTo.month, p.dateTo.day, p.dateTo.hour, p.dateTo.minute).millisecondsSinceEpoch;
        final val = (p.value is num) ? (p.value as num).toDouble() : double.tryParse(p.value.toString()) ?? 0.0;
        if (val <= 0) continue;
        grouped.putIfAbsent(tsKey, () => {});
        grouped[tsKey]![p.type] = val;
      }

      for (final entry in grouped.entries) {
        final ts = DateTime.fromMillisecondsSinceEpoch(entry.key);
        final systolic = entry.value[HealthDataType.BLOOD_PRESSURE_SYSTOLIC];
        final diastolic = entry.value[HealthDataType.BLOOD_PRESSURE_DIASTOLIC];
        if (systolic == null) continue; // require systolic to submit
        final res = await _api.submitHealthData(
          token,
          type: HealthType.bloodPressure,
          value: systolic,
          unit: 'mmHg',
          timestamp: ts,
          additionalData: diastolic != null ? {'diastolic': diastolic} : null,
        );
        if (res['success'] == true) submitted++;
      }
      return submitted;
    }

    // Unsupported mapping: return 0
    return 0;
  }

  /// Convenience: import and submit records for all supported fields.
  Future<int> importAndSubmitAll({
    required String token,
    int daysBack = 30,
  }) async {
    int total = 0;
    for (final t in [HealthType.heartRate, HealthType.bloodPressure, HealthType.temperature]) {
      total += await importAndSubmitSelectedType(type: t, token: token, daysBack: daysBack);
    }
    return total;
  }
}
