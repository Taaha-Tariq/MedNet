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
            // Mock data for now - replace with actual data parsing
            _healthData = {
              HealthType.heartRate: 72.0,
              HealthType.bloodPressure: 120.0, // Systolic
              HealthType.temperature: 36.5,
            };
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
                      _healthData[HealthType.heartRate] ?? 0,
                    ),
                    const SizedBox(height: 16),
                    _buildHealthCard(
                      context,
                      HealthType.bloodPressure,
                      _healthData[HealthType.bloodPressure] ?? 0,
                    ),
                    const SizedBox(height: 16),
                    _buildHealthCard(
                      context,
                      HealthType.temperature,
                      _healthData[HealthType.temperature] ?? 0,
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
    double value,
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
                        value > 0
                            ? value.toStringAsFixed(
                                type == HealthType.temperature ? 1 : 0)
                            : '--',
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
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshHealthData(type),
              color: AppTheme.calmBlue,
            ),
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
    // Show dialog or navigate to metric input screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check ${type.displayName}'),
        content: Text(
          'This feature will connect to your health monitoring device or allow manual entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to input screen or trigger device connection
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${type.displayName} check initiated'),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}


