import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/bid_service.dart';
import '../../models/bid_model.dart';

// Shows bids as they come in on a bidding-mode order, polling every 5s
// since bids arrive asynchronously from drivers browsing their own
// available-orders list (SRS bidding pricing mode).
class BidsScreen extends ConsumerStatefulWidget {
  final String orderId;
  const BidsScreen({super.key, required this.orderId});

  @override
  ConsumerState<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends ConsumerState<BidsScreen> {
  final _bidService = BidService();
  List<BidModel>? _bids;
  String? _error;
  String? _acceptingId;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final bids = await _bidService.listBidsForOrder(widget.orderId);
      if (mounted) setState(() => _bids = bids);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load bids.');
    }
  }

  Future<void> _accept(BidModel bid) async {
    setState(() => _acceptingId = bid.id);
    try {
      await _bidService.acceptBid(bid.id);
      _pollTimer?.cancel();
      if (mounted) context.pushReplacement('/booking/detail/${widget.orderId}');
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not accept this bid. Try again.');
    } finally {
      if (mounted) setState(() => _acceptingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bids received')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _bids == null
            ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
            : _bids!.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No bids yet - drivers matching your vehicle type will see this booking and can bid. Pull to refresh.')),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bids!.length,
                    itemBuilder: (context, i) {
                      final bid = _bids![i];
                      final accepting = _acceptingId == bid.id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(child: Icon(Icons.person)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(bid.driverName ?? 'Driver', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${bid.vehicleNumber ?? ''} · ${bid.driverRating?.toStringAsFixed(1) ?? '—'} ★ · ${bid.driverTotalTrips ?? 0} trips',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${bid.amount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 32,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), textStyle: const TextStyle(fontSize: 12)),
                                      onPressed: accepting ? null : () => _accept(bid),
                                      child: accepting
                                          ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Accept'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
