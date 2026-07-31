import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/payment_service.dart';

// Customer-app "Payment Methods" - Razorpay Standard Checkout doesn't
// expose a saved-cards list via our current integration (that needs
// Razorpay's separate tokenization APIs), so this shows what actually
// exists today: real past transactions, via the already-built
// GET /payment/history endpoint.
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _service = PaymentService();
  List<PaymentRecord>? _payments;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final payments = await _service.getHistory();
      if (mounted) setState(() => _payments = payments);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load payment history.');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'captured':
        return AppTheme.success;
      case 'refunded':
        return Colors.orange;
      case 'failed':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Payment Methods')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _payments == null
              ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
              : _payments!.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text('No payments yet.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _payments!.length,
                      itemBuilder: (context, index) {
                        final p = _payments![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(Icons.receipt_long_outlined, color: _statusColor(p.status)),
                            title: Text('₹${(p.amount / 100).toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              [
                                if (p.orderPickupAddress != null) p.orderPickupAddress!,
                                '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _statusColor(p.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text(p.status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(p.status))),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
