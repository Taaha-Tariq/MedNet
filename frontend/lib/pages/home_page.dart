import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_data_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Map<HealthType, double?> _healthData = {};
  bool _isLoading = false;
  double? _bpDiastolic; // store diastolic for blood pressure

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final result = await _apiService.getCurrentHealthData(token);
        if (result['success'] == true && mounted) {
          // Parse health data from response
          // This will depend on your backend structure
          setState(() {
            // Initial load: leave metrics unset (bars) until manual entry
            _healthData = {
              HealthType.heartRate: null,
              HealthType.bloodPressure: null,
              HealthType.temperature: null,
            };
            _bpDiastolic = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppTheme.calmBlue,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveThreeMetrics,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        backgroundColor: AppTheme.calmBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHealthData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Metrics',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your vital signs',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildHealthCard(
                      context,
                      HealthType.heartRate,
                      _healthData[HealthType.heartRate],
                    ),
                    const SizedBox(height: 16),
                    _buildHealthCard(
                      context,
                      HealthType.bloodPressure,
                      _healthData[HealthType.bloodPressure],
                    ),
                    const SizedBox(height: 16),
                    _buildHealthCard(
                      context,
                      HealthType.temperature,
                      _healthData[HealthType.temperature],
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHealthCard(
    BuildContext context,
    HealthType type,
    double? value,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.calmBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        () {
                          if (type == HealthType.bloodPressure) {
                            final sys = (value != null && value > 0)
                                ? value.toStringAsFixed(0)
                                : '—';
                            final dia = (_bpDiastolic != null && _bpDiastolic! > 0)
                                ? _bpDiastolic!.toStringAsFixed(0)
                                : '—';
                            return '$sys/$dia';
                          }
                          return (value != null && value > 0)
                              ? value.toStringAsFixed(
                                  type == HealthType.temperature ? 1 : 0)
                              : '—';
                        }(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.calmBlue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.unit,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.coolGraphite,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(children: [
              IconButton(
                tooltip: 'Manual entry',
                icon: const Icon(Icons.edit),
                onPressed: () => _showManualEntryDialog(type),
                color: AppTheme.calmBlue,
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshHealthData(type),
                color: AppTheme.calmBlue,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Check Heart Rate',
                Icons.favorite,
                HealthType.heartRate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Blood Pressure',
                Icons.monitor_heart,
                HealthType.bloodPressure,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Temperature',
                Icons.thermostat,
                HealthType.temperature,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Blood Sugar',
                Icons.bloodtype,
                HealthType.bloodSugar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    HealthType type,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _handleCheckMetric(type),
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _refreshHealthData(HealthType type) async {
    // Simulate fetching data - replace with actual API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fetching ${type.displayName}...'),
        duration: const Duration(seconds: 1),
      ),
    );
    
    // Mock data update
    setState(() {
      switch (type) {
        case HealthType.heartRate:
          _healthData[type] = 72.0 + (DateTime.now().millisecond % 20 - 10);
          break;
        case HealthType.bloodPressure:
          _healthData[type] = 120.0 + (DateTime.now().millisecond % 10 - 5);
          break;
        case HealthType.temperature:
          _healthData[type] = 36.5 + (DateTime.now().millisecond % 10 - 5) / 10;
          break;
        case HealthType.bloodSugar:
          _healthData[type] = 90.0 + (DateTime.now().millisecond % 20 - 10);
          break;
      }
    });
  }

  Future<void> _handleCheckMetric(HealthType type) async {
    // Directly open manual entry for now
    _showManualEntryDialog(type);
  }

  Future<void> _saveThreeMetrics() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    // Require all metrics to be entered before saving
    final hr = _healthData[HealthType.heartRate];
    final bpSys = _healthData[HealthType.bloodPressure];
    final temp = _healthData[HealthType.temperature];
    if (hr == null || bpSys == null || temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter all metrics before saving')),
      );
      return;
    }

    results.add(await _apiService.submitHealthData(
      token,
      type: HealthType.heartRate,
      value: hr,
      unit: HealthType.heartRate.unit,
      timestamp: now,
      additionalData: { 'source': 'HomePageSave' },
    ));

    results.add(await _apiService.submitHealthData(
      token,
      type: HealthType.bloodPressure,
      value: bpSys,
      unit: HealthType.bloodPressure.unit,
      timestamp: now,
      additionalData: {
        if (_bpDiastolic != null) 'diastolic': _bpDiastolic,
        'source': 'HomePageSave'
      },
    ));

    results.add(await _apiService.submitHealthData(
      token,
      type: HealthType.temperature,
      value: temp,
      unit: HealthType.temperature.unit,
      timestamp: now,
      additionalData: { 'source': 'HomePageSave' },
    ));

    final allOk = results.every((r) => r['success'] == true);
    if (allOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved heart rate, blood pressure, and temperature')),
      );
      _loadHealthData();
    } else {
      final firstErr = results.firstWhere(
        (r) => r['success'] != true,
        orElse: () => {'message': 'Failed to save some data'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firstErr['message'] ?? 'Failed to save some data')),
      );
    }
  }

  Future<void> _showManualEntryDialog(HealthType type) async {
    final token = await _authService.getToken();
    // Token not required for local-only edits; will be used on Save FAB

    final valueController = TextEditingController();
    final diastolicController = TextEditingController(); // for BP optional
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add ${type.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: type == HealthType.bloodPressure ? 'Systolic (${type.unit})' : 'Value (${type.unit})',
                  hintText: type == HealthType.temperature ? 'e.g., 36.7' : null,
                  errorText: errorText,
                ),
              ),
              if (type == HealthType.bloodPressure) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: diastolicController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Diastolic (mmHg)',
                    hintText: 'e.g., 80',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final txt = valueController.text.trim();
                final val = double.tryParse(txt);
                if (val == null) {
                  setState(() => errorText = 'Enter a valid number');
                  return;
                }

                // Update local state only; backend save happens via FAB
                setState(() => errorText = null);
                Navigator.pop(context);
                this.setState(() {
                  _healthData[type] = val;
                  if (type == HealthType.bloodPressure) {
                    final dTxt = diastolicController.text.trim();
                    final dia = double.tryParse(dTxt);
                    _bpDiastolic = dia;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${type.displayName} updated locally')),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}


