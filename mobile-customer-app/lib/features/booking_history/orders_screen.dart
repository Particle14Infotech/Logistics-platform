import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/order_model.dart';

// Canonical filter keys - `label` is resolved from AppLocalizations at
// build time in _filterLabel below, since a top-level const can't call
// context-dependent code.
const _kFilters = [
  (label: 'All', status: null),
  (label: 'Active', status: 'active'), // client-side: pending/accepted/picked_up/in_transit
  (label: 'Delivered', status: 'delivered'),
  (label: 'Cancelled', status: 'cancelled'),
];

// Full booking history (SRS 3.1.10 Order History). Home only shows the
// 5 most recent bookings - this is the complete list with filtering.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  List<OrderModel>? _orders;
  String? _error;
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    try {
      final orders = await ref.read(bookingServiceProvider).listMyBookings(user.id);
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.couldNotLoadYourOrders);
      }
    }
  }

  List<OrderModel> get _filtered {
    if (_orders == null) return [];
    final status = _kFilters[_filterIndex].status;
    if (status == null) return _orders!;
    if (status == 'active') return _orders!.where((o) => !['delivered', 'cancelled'].contains(o.status)).toList();
    return _orders!.where((o) => o.status == status).toList();
  }

  String _filterLabel(String key, AppLocalizations l10n) => switch (key) {
        'All' => l10n.filterAll,
        'Active' => l10n.filterActive,
        'Delivered' => l10n.statusDelivered,
        'Cancelled' => l10n.statusCancelled,
        _ => key,
      };

  String _statusLabel(String status, AppLocalizations l10n) => switch (status) {
        'pending' => l10n.statusPending,
        'accepted' => l10n.statusAccepted,
        'picked_up' || 'in_transit' => l10n.statusInTransit,
        'awaiting_payment' => l10n.statusAwaitingPayment,
        'delivered' => l10n.statusDelivered,
        'cancelled' => l10n.statusCancelled,
        _ => status.replaceAll('_', ' ').toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOrders)),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _kFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filterIndex;
                return ChoiceChip(
                  label: Text(_filterLabel(_kFilters[i].label, l10n)),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterIndex = i),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _orders == null
                  ? (_error != null ? Center(child: Text(_error!)) : const Center(child: CircularProgressIndicator()))
                  : _filtered.isEmpty
                      ? ListView(children: [Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.noOrdersHereYet)))])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) {
                            final order = _filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () => context.push('/booking/detail/${order.id}'),
                                leading: CircleAvatar(child: Icon(_iconFor(order.vehicleType))),
                                title: Text('${order.pickupLocation.address} → ${order.dropLocation.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${_statusLabel(order.status, l10n)} · ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                                trailing: Text('₹${order.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String vehicleType) => switch (vehicleType) {
        'bike' => Icons.two_wheeler,
        'auto' => Icons.electric_rickshaw,
        'large_truck' => Icons.fire_truck,
        _ => Icons.local_shipping,
      };
}
