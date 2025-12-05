import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_data_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  HealthType _selectedType = HealthType.heartRate;
  List<HealthData> _healthHistory = [];
  bool _isLoading = false;
  Map<String, dynamic>? _currentSummary; // holds latest metrics summary or array

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadCurrentSummary();
    await _loadHealthHistory();
  }

  Future<void> _loadCurrentSummary() async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final result = await _apiService.getCurrentHealthData(token);
        if (result['success'] == true && mounted) {
          setState(() {
            _currentSummary = result['data'] as Map<String, dynamic>;
          });
        }
      }
    } catch (_) {
      // ignore errors for summary
    }
  }

  Future<void> _loadHealthHistory() async {
    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final result = await _apiService.getHealthHistory(
          token,
          type: _selectedType,
        );

        if (result['success'] == true && mounted) {
          final data = result['data'];
          if (data is List) {
            setState(() {
              _healthHistory = data
                  .map((item) => HealthData.fromJson(item))
                  .toList();
            });
          } else if (data is Map && data['data'] is List) {
            setState(() {
              _healthHistory = (data['data'] as List)
                  .map((item) => HealthData.fromJson(item))
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: ${e.toString()}')),
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
        title: const Text('Health Analysis'),
        backgroundColor: AppTheme.calmBlue,
      ),
      body: Column(
        children: [
          // Current Summary Cards
          if (_currentSummary != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildSummaryCards(context),
              ),
            ),
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HealthType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(type.icon),
                          const SizedBox(width: 4),
                          Text(type.displayName),
                        ],
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = type;
                          });
                          _loadHealthHistory();
                        }
                      },
                      selectedColor: AppTheme.calmBlue,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.coolGraphite,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _healthHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: AppTheme.coolGraphite,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No health data available',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.coolGraphite,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start tracking your health metrics',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHealthHistory,
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            if (_currentSummary == null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  'No summary available yet',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            // Graph placeholder
                            Card(
                              child: Container(
                                height: 200,
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_selectedType.displayName} Trends',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '📈 Graph will be displayed here',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppTheme.coolGraphite,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Recent Records',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 12),
                            // History List
                            ..._healthHistory.take(10).map((data) => Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppTheme.calmBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _selectedType.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${data.value.toStringAsFixed(_selectedType == HealthType.temperature ? 1 : 0)} ${data.unit}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                    subtitle: Text(
                                      _formatDate(data.timestamp),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppTheme.coolGraphite,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  List<Widget> _buildSummaryCards(BuildContext context) {
    final cards = <Widget>[];
    final summary = _currentSummary!;
    // If backend returned compact keys
    void addCard(String title, String key, String unit, String icon) {
      final value = summary[key];
      if (value != null) {
        cards.add(_metricCard(context, title, value.toString(), unit, icon));
      }
    }
    addCard('Heart Rate', 'heartRate', 'bpm', '❤️');
    addCard('Blood Pressure', 'bloodPressure', 'mmHg', '🩺');
    addCard('Temperature', 'temperature', '°C', '🌡️');
    addCard('Blood Sugar', 'bloodSugar', 'mg/dL', '🍬');

    // Or if backend returned array under data
    if (summary['data'] is List && (summary['data'] as List).isNotEmpty) {
      for (final item in (summary['data'] as List)) {
        final type = (item['type'] ?? '').toString();
        final value = item['value']?.toString();
        final unit = item['unit']?.toString() ?? '';
        if (value == null) continue;
        switch (type) {
          case 'heartRate':
            cards.add(_metricCard(context, 'Heart Rate', value, unit, '❤️'));
            break;
          case 'bloodPressure':
            cards.add(_metricCard(context, 'Blood Pressure', value, unit, '🩺'));
            break;
          case 'temperature':
            cards.add(_metricCard(context, 'Temperature', value, unit, '🌡️'));
            break;
          case 'bloodSugar':
            cards.add(_metricCard(context, 'Blood Sugar', value, unit, '🍬'));
            break;
        }
      }
    }
    return cards;
  }

  Widget _metricCard(BuildContext context, String title, String value, String unit, String icon) {
    return Card(
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('$value $unit', style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    );
  }
}


