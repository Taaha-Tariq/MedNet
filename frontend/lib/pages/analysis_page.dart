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

  @override
  void initState() {
    super.initState();
    _loadHealthHistory();
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
}


