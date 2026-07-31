import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import '../services/razorpay_checkout_helper.dart';

// Shared by booking_confirmation_screen.dart and booking_detail_screen.dart -
// both need the identical create-order -> open Checkout -> verify flow, just
// with a different onPaid callback (refresh the order afterwards).
class PayNowButton extends ConsumerStatefulWidget {
  final String orderId;
  final VoidCallback onPaid;
  const PayNowButton({super.key, required this.orderId, required this.onPaid});

  @override
  ConsumerState<PayNowButton> createState() => _PayNowButtonState();
}

class _PayNowButtonState extends ConsumerState<PayNowButton> {
  final _paymentService = PaymentService();
  bool _paying = false;
  String? _error;

  Future<void> _payNow() async {
    setState(() {
      _paying = true;
      _error = null;
    });
    final helper = RazorpayCheckoutHelper();
    try {
      final orderDetails = await _paymentService.createOrder(widget.orderId);
      final user = ref.read(authProvider).user;
      final result = await helper.open(
        keyId: orderDetails.keyId,
        razorpayOrderId: orderDetails.razorpayOrderId,
        amountPaise: orderDetails.amount,
        currency: orderDetails.currency,
        name: 'RaahMitr',
        description: 'Shipment payment',
        contact: user?.phone,
        email: user?.email,
      );

      if (result.success) {
        await _paymentService.verifyPayment(
          razorpayOrderId: result.orderId!,
          razorpayPaymentId: result.paymentId!,
          razorpaySignature: result.signature!,
        );
        widget.onPaid();
      } else {
        setState(() => _error = result.errorMessage ?? 'Payment was not completed.');
      }
    } catch (e) {
      setState(() => _error = 'Could not complete the payment. Try again.');
    } finally {
      helper.dispose();
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _paying ? null : _payNow,
          icon: _paying
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.payment),
          label: Text(_paying ? 'Opening payment…' : 'Pay Now'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 12), textAlign: TextAlign.center),
        ],
      ],
    );
  }
}
