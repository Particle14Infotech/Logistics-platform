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
  WalletSummary? _wallet;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ref.read(driverServiceProvider).getEarnings(),
        ref.read(driverServiceProvider).getWallet(),
      ]);
      if (mounted) {
        setState(() {
          _earnings = results[0] as EarningsSummary;
          _wallet = results[1] as WalletSummary;
        });
      }
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
                  if (_wallet != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Wallet balance', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text('₹${_wallet!.balance}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Icon(Icons.account_balance_wallet_outlined),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_wallet!.transactions.isNotEmpty) ...[
                      const Text('Recent activity', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ..._wallet!.transactions.take(20).map((t) => _WalletTransactionTile(transaction: t)),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}

class _WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  const _WalletTransactionTile({required this.transaction});

  static const _labels = {
    'trip_earning': 'Trip fare',
    'cancellation_compensation': 'Cancellation compensation',
    'payout': 'Payout',
    'adjustment': 'Adjustment',
  };

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount >= 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? Colors.green : Colors.red,
        ),
        title: Text(_labels[transaction.type] ?? transaction.type),
        subtitle: Text(
          '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}'
          '${transaction.note != null ? ' · ${transaction.note}' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${transaction.amount.abs()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green : Colors.red,
          ),
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
