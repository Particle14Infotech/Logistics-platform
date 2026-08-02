import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
    final order = _order;
    return Scaffold(
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
              Text('Booking Confirmed!',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                "Your shipment has been successfully booked.",
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
                            Text('Estimated Price',
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
                                ? 'Pay ₹${order.advanceAmount} now, ₹${order.price - order.advanceAmount} in cash at delivery'
                                : 'Pay ₹${order.price} in cash at delivery - no advance required',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ] else if (order.advanceAmount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Pay ₹${order.advanceAmount} now, remaining ₹${order.price - order.advanceAmount} due online near delivery',
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
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      context.go('/booking/detail/${widget.orderId}'),
                  child: const Text('Track Shipment'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
