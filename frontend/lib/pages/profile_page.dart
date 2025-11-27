import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  User? _user;
  bool _isLoading = false;
  bool _isEditing = false;
  File? _selectedImage;
  String? _tempProfileImageUrl;

  // Controllers for all fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // Blood group options
  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Gender options
  static const List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _medicalConditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final result = await _apiService.getUserProfile(token);
        if (result['success'] == true && mounted) {
          setState(() {
            _user = User.fromJson(result['data']);
            _populateControllers();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateControllers() {
    if (_user == null) return;
    
    _nameController.text = _user!.fullName;
    _emailController.text = _user!.email;
    _ageController.text = _user!.age.toString();
    _phoneController.text = _user!.phoneNumber ?? '';
    _heightController.text = _user!.height?.toString() ?? '';
    _weightController.text = _user!.weight?.toString() ?? '';
    _allergiesController.text = _user!.allergies ?? '';
    _medicationsController.text = _user!.medications ?? '';
    _medicalConditionsController.text = _user!.medicalConditions ?? '';
    _emergencyNameController.text = _user!.emergencyContactName ?? '';
    _emergencyPhoneController.text = _user!.emergencyContactPhone ?? '';
    _emergencyRelationController.text = _user!.emergencyContactRelation ?? '';
    
    _selectedBloodGroup = _user!.bloodGroup;
    _selectedGender = _user!.gender;
    _selectedDateOfBirth = _user!.dateOfBirth;
    _tempProfileImageUrl = _user!.profileImageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.calmBlue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.calmBlue),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_tempProfileImageUrl != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _tempProfileImageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.calmBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age <= 0 || age > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return;
    }

    final height = _heightController.text.isNotEmpty 
        ? double.tryParse(_heightController.text) 
        : null;
    final weight = _weightController.text.isNotEmpty 
        ? double.tryParse(_weightController.text) 
        : null;

    if (height != null && (height <= 0 || height > 300)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid height (in cm)')),
      );
      return;
    }

    if (weight != null && (weight <= 0 || weight > 500)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight (in kg)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token != null) {
        // TODO: Upload image to server and get URL
        // For now, we'll keep the existing profileImageUrl or use a placeholder
        String? profileImageUrl = _tempProfileImageUrl;
        if (_selectedImage != null) {
          // In a real app, you would upload the image to your server here
          // profileImageUrl = await _uploadImage(_selectedImage);
          // For now, we'll just keep the existing URL
        }

        final result = await _apiService.updateUserProfile(
          token,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          age: age,
          bloodGroup: _selectedBloodGroup,
          gender: _selectedGender,
          height: height,
          weight: weight,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          dateOfBirth: _selectedDateOfBirth,
          allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
          medications: _medicationsController.text.trim().isEmpty ? null : _medicationsController.text.trim(),
          medicalConditions: _medicalConditionsController.text.trim().isEmpty ? null : _medicalConditionsController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim().isEmpty ? null : _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
          emergencyContactRelation: _emergencyRelationController.text.trim().isEmpty ? null : _emergencyRelationController.text.trim(),
          profileImageUrl: profileImageUrl,
        );

        if (result['success'] == true && mounted) {
          setState(() {
            _isEditing = false;
            _user = User.fromJson(result['data']);
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.seaGreen,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      _populateControllers();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.calmBlue,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
            ),
        ],
      ),
      body: _isLoading && _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture Section with Edit Button
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _isEditing ? _showImagePickerOptions : null,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.calmBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _tempProfileImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _tempProfileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.person, size: 60, color: Colors.white),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.seaGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.white, width: 3),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              onPressed: _showImagePickerOptions,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user?.fullName ?? 'Loading...',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.navy,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.coolGraphite,
                        ),
                  ),
                  if (_user?.bmi != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.seaGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.seaGreen, width: 1),
                      ),
                      child: Text(
                        'BMI: ${_user!.bmi!.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Personal Information Card
                  _buildSectionCard(
                    context,
                    'Personal Information',
                    Icons.person_outline,
                    [
                      _buildEditableField(
                        context,
                        'Full Name',
                        _nameController,
                        Icons.person_outlined,
                        enabled: _isEditing,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Email',
                        _emailController,
                        Icons.email_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Age',
                        _ageController,
                        Icons.calendar_today_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Phone Number',
                        _phoneController,
                        Icons.phone_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildDatePickerField(
                        context,
                        'Date of Birth',
                        _selectedDateOfBirth,
                        Icons.cake_outlined,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        context,
                        'Gender',
                        _selectedGender,
                        _genders,
                        Icons.wc_outlined,
                        enabled: _isEditing,
                        onChanged: (value) => setState(() => _selectedGender = value),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Medical Information Card
                  _buildSectionCard(
                    context,
                    'Medical Information',
                    Icons.medical_information_outlined,
                    [
                      _buildDropdownField(
                        context,
                        'Blood Group',
                        _selectedBloodGroup,
                        _bloodGroups,
                        Icons.bloodtype_outlined,
                        enabled: _isEditing,
                        onChanged: (value) => setState(() => _selectedBloodGroup = value),
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Height (cm)',
                        _heightController,
                        Icons.height_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Weight (kg)',
                        _weightController,
                        Icons.monitor_weight_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Allergies',
                        _allergiesController,
                        Icons.warning_outlined,
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Medications',
                        _medicationsController,
                        Icons.medication_outlined,
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Medical Conditions',
                        _medicalConditionsController,
                        Icons.health_and_safety_outlined,
                        enabled: _isEditing,
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Emergency Contact Card
                  _buildSectionCard(
                    context,
                    'Emergency Contact',
                    Icons.emergency_outlined,
                    [
                      _buildEditableField(
                        context,
                        'Contact Name',
                        _emergencyNameController,
                        Icons.person_outlined,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Contact Phone',
                        _emergencyPhoneController,
                        Icons.phone_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        context,
                        'Relationship',
                        _emergencyRelationController,
                        Icons.family_restroom_outlined,
                        enabled: _isEditing,
                      ),
                    ],
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.calmBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.calmBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.navy,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = false,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    if (enabled) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: '$label${required ? ' *' : ''}',
          prefixIcon: Icon(icon, color: AppTheme.calmBlue),
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.fogGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.fogGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.calmBlue, width: 2),
          ),
        ),
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: AppTheme.calmBlue),
        title: Text(label),
        subtitle: Text(
          controller.text.isEmpty ? 'Not set' : controller.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: controller.text.isEmpty 
                    ? AppTheme.coolGraphite.withOpacity(0.6)
                    : AppTheme.navy,
              ),
        ),
        contentPadding: EdgeInsets.zero,
      );
    }
  }

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    String? value,
    List<String> items,
    IconData icon, {
    bool enabled = false,
    required Function(String?) onChanged,
  }) {
    if (enabled) {
      return DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.calmBlue),
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.fogGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.fogGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.calmBlue, width: 2),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: AppTheme.calmBlue),
        title: Text(label),
        subtitle: Text(
          value ?? 'Not set',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: value == null 
                    ? AppTheme.coolGraphite.withOpacity(0.6)
                    : AppTheme.navy,
              ),
        ),
        contentPadding: EdgeInsets.zero,
      );
    }
  }

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    DateTime? value,
    IconData icon, {
    bool enabled = false,
  }) {
    if (enabled) {
      return InkWell(
        onTap: _selectDateOfBirth,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppTheme.calmBlue),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.fogGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.fogGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.calmBlue, width: 2),
            ),
          ),
          child: Text(
            value != null
                ? '${value.day}/${value.month}/${value.year}'
                : 'Select date',
            style: TextStyle(
              color: value != null ? AppTheme.navy : AppTheme.coolGraphite.withOpacity(0.6),
            ),
          ),
        ),
      );
    } else {
      return ListTile(
        leading: Icon(icon, color: AppTheme.calmBlue),
        title: Text(label),
        subtitle: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Not set',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: value == null 
                    ? AppTheme.coolGraphite.withOpacity(0.6)
                    : AppTheme.navy,
              ),
        ),
        contentPadding: EdgeInsets.zero,
      );
    }
  }
}
