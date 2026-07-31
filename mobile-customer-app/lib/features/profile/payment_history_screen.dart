import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../services/payment_service.dart';

// Customer-app "Payment Methods" - saved cards (tokenized against a
// Razorpay Customer, see razorpay.service.js's ensureCustomer/listSavedCards
// - opened at least once via Pay Now with "save this card" checked) plus
// the transaction history that was previously the only thing this screen
// could show at all.
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _service = PaymentService();
  List<PaymentRecord>? _payments;
  List<SavedCard>? _cards;
  String? _error;
  String? _removingTokenId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([_service.getHistory(), _service.getSavedCards()]);
      if (mounted) {
        setState(() {
          _payments = results[0] as List<PaymentRecord>;
          _cards = results[1] as List<SavedCard>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load payment history.');
    }
  }

  Future<void> _removeCard(SavedCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove card?'),
        content: Text('Remove the ${card.network} card ending in ${card.last4}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _removingTokenId = card.tokenId);
    try {
      await _service.deleteSavedCard(card.tokenId);
      if (mounted) setState(() => _cards = _cards?.where((c) => c.tokenId != card.tokenId).toList());
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not remove that card.');
    } finally {
      if (mounted) setState(() => _removingTokenId = null);
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

  IconData _cardIcon(String network) {
    switch (network.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _payments == null || _cards == null;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Payment Methods')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: loading
              ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Saved cards', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    if (_cards!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No saved cards yet - check "Save this card" during your next payment.',
                          style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade500),
                        ),
                      )
                    else
                      ..._cards!.map((card) => Card(
                            margin: const EdgeInsets.only(top: 8),
                            child: ListTile(
                              leading: Icon(_cardIcon(card.network), color: AppTheme.primary),
                              title: Text('${card.network} •••• ${card.last4}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5)),
                              subtitle: card.type != null ? Text(card.type!, style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade500)) : null,
                              trailing: _removingTokenId == card.tokenId
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _removeCard(card)),
                            ),
                          )),
                    const SizedBox(height: 24),
                    Text('Transaction history', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    if (_payments!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text('No payments yet.', style: GoogleFonts.poppins(color: Colors.grey.shade500)),
                      )
                    else
                      ..._payments!.map((p) => Card(
                            margin: const EdgeInsets.only(top: 8),
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
                          )),
                  ],
                ),
        ),
      ),
    );
  }
}
