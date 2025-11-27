class User {
  final String id;
  final String fullName;
  final String email;
  final int age;
  String? profileImageUrl;
  
  // Medical Information Fields
  String? bloodGroup;
  String? gender;
  double? height; // in cm
  double? weight; // in kg
  String? phoneNumber;
  DateTime? dateOfBirth;
  String? allergies;
  String? medications;
  String? medicalConditions;
  String? emergencyContactName;
  String? emergencyContactPhone;
  String? emergencyContactRelation;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.age,
    this.profileImageUrl,
    this.bloodGroup,
    this.gender,
    this.height,
    this.weight,
    this.phoneNumber,
    this.dateOfBirth,
    this.allergies,
    this.medications,
    this.medicalConditions,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      bloodGroup: json['bloodGroup'] ?? json['blood_group'],
      gender: json['gender'],
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : (json['date_of_birth'] != null 
              ? DateTime.parse(json['date_of_birth']) 
              : null),
      allergies: json['allergies'],
      medications: json['medications'],
      medicalConditions: json['medicalConditions'] ?? json['medical_conditions'],
      emergencyContactName: json['emergencyContactName'] ?? json['emergency_contact_name'],
      emergencyContactPhone: json['emergencyContactPhone'] ?? json['emergency_contact_phone'],
      emergencyContactRelation: json['emergencyContactRelation'] ?? json['emergency_contact_relation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'age': age,
      'profileImageUrl': profileImageUrl,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'height': height,
      'weight': weight,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'allergies': allergies,
      'medications': medications,
      'medicalConditions': medicalConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    int? age,
    String? profileImageUrl,
    String? bloodGroup,
    String? gender,
    double? height,
    double? weight,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? allergies,
    String? medications,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
    );
  }
  
  // Helper method to calculate BMI
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }
}


