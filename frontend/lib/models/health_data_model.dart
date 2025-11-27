class HealthData {
  final String id;
  final String userId;
  final HealthType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  HealthData({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.additionalData,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: HealthType.fromString(json['type'] ?? ''),
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      additionalData: json['additionalData'] ?? json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'additionalData': additionalData,
    };
  }
}

enum HealthType {
  heartRate,
  bloodPressure,
  temperature,
  bloodSugar;

  static HealthType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'heartrate':
      case 'heart_rate':
        return HealthType.heartRate;
      case 'bloodpressure':
      case 'blood_pressure':
        return HealthType.bloodPressure;
      case 'temperature':
        return HealthType.temperature;
      case 'bloodsugar':
      case 'blood_sugar':
      case 'sugar':
        return HealthType.bloodSugar;
      default:
        return HealthType.heartRate;
    }
  }

  String get displayName {
    switch (this) {
      case HealthType.heartRate:
        return 'Heart Rate';
      case HealthType.bloodPressure:
        return 'Blood Pressure';
      case HealthType.temperature:
        return 'Temperature';
      case HealthType.bloodSugar:
        return 'Blood Sugar';
    }
  }

  String get unit {
    switch (this) {
      case HealthType.heartRate:
        return 'bpm';
      case HealthType.bloodPressure:
        return 'mmHg';
      case HealthType.temperature:
        return '°C';
      case HealthType.bloodSugar:
        return 'mg/dL';
    }
  }

  String get icon {
    switch (this) {
      case HealthType.heartRate:
        return '❤️';
      case HealthType.bloodPressure:
        return '🩺';
      case HealthType.temperature:
        return '🌡️';
      case HealthType.bloodSugar:
        return '🍬';
    }
  }
}


