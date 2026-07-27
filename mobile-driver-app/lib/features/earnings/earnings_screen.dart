import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/driver_provider.dart';
import '../../services/driver_service.dart';

// Earnings dashboard: daily/weekly earnings, trip count (SRS 3.2.6).
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  EarningsSummary? _earnings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final earnings = await ref.read(driverServiceProvider).getEarnings();
      if (mounted) setState(() => _earnings = earnings);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load earnings.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _earnings;
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: e == null
            ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text('Total lifetime earnings', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('₹${e.totalEarnings}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('${e.totalTrips} trips completed', style: TextStyle(color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _PeriodCard(label: 'This week', total: e.weekTotal, trips: e.weekTrips)),
                      const SizedBox(width: 12),
                      Expanded(child: _PeriodCard(label: 'This month', total: e.monthTotal, trips: e.monthTrips)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String label;
  final num total;
  final int trips;
  const _PeriodCard({required this.label, required this.total, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('$trips trips', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
