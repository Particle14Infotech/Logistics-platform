import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/pay_now_button.dart';

// Matches the reference design's 'Booking Confirmed!' screen - fetches the
// real order so the confirmation card shows actual pickup/drop/price
// rather than just the booking ID.
class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String orderId;
  const BookingConfirmationScreen({super.key, required this.orderId});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order =
          await ref.read(bookingServiceProvider).getBooking(widget.orderId);
      if (mounted) setState(() => _order = order);
    } catch (_) {
      // Non-critical - the confirmation still shows without the order card.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final order = _order;
    return PopScope(
      // The wizard screens behind this one (Locations/Vehicle/Details) are
      // still on the stack since they now use push, not pushReplacement -
      // but their draft was just reset() in fare_estimate_screen.dart, so
      // popping back into them would land on stale/empty steps for an
      // order that's already been placed. Route back-button/back-gesture
      // to Home instead, same as the explicit "Back to Home" button below.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child:
                    const Icon(Icons.check, size: 48, color: AppTheme.success),
              ),
              const SizedBox(height: 24),
              Text(l10n.bookingConfirmed,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l10n.shipmentBookedSuccessfully,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.borderColor)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '#${widget.orderId.substring(widget.orderId.length - 8).toUpperCase()}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),
                      if (order != null) ...[
                        Row(children: [
                          const Icon(Icons.trip_origin,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(order.pickupLocation.address,
                                  style: GoogleFonts.poppins(fontSize: 12)))
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(order.dropLocation.address,
                                  style: GoogleFonts.poppins(fontSize: 12)))
                        ]),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.estimatedPrice,
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey.shade500)),
                            Text('₹${order.price}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.primary)),
                          ],
                        ),
                        if (order.paymentMethod == 'cod') ...[
                          const SizedBox(height: 4),
                          Text(
                            order.advanceAmount > 0
                                ? l10n.payAdvanceNowCashAtDelivery(
                                    '${order.advanceAmount}', '${order.price - order.advanceAmount}')
                                : l10n.payCashAtDeliveryNoAdvance('${order.price}'),
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ] else if (order.advanceAmount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.payAdvanceNowRemainingOnlineNearDelivery(
                                '${order.advanceAmount}', '${order.price - order.advanceAmount}'),
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ] else
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (order != null && order.paymentStatus == 'unpaid') ...[
                PayNowButton(
                  orderId: order.id,
                  onPaid: _load,
                  isAdvance: order.advanceAmount > 0,
                ),
                const SizedBox(height: 8),
              ],
              if (order != null &&
                  order.paymentMethod == 'online' &&
                  order.paymentStatus == 'paid' &&
                  order.advanceAmount > 0 &&
                  !order.remainderPaid) ...[
                PayNowButton(
                  orderId: order.id,
                  onPaid: _load,
                  isRemainder: true,
                ),
                const SizedBox(height: 8),
              ],
              // A booking with an unpaid advance isn't a live, trackable
              // order yet - it's not visible to any driver either (see
              // driver.controller.js's availableOrders) until this advance
              // clears, so there's genuinely nothing to track. Only offer
              // Track Shipment once that's no longer true.
              if (order == null || order.advanceAmount == 0 || order.paymentStatus == 'paid') ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // push, not go - go() wipes the whole stack down to
                    // just this route, and booking_detail_screen.dart has
                    // no PopScope of its own, so a lone back press/gesture
                    // there had nothing left to pop and exited the app
                    // outright instead of returning here.
                    onPressed: () =>
                        context.push('/booking/detail/${widget.orderId}'),
                    child: Text(l10n.trackShipment),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                Text(
                  l10n.trackShipmentAvailableOnceAdvanceConfirmed,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: Text(l10n.backToHome),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
