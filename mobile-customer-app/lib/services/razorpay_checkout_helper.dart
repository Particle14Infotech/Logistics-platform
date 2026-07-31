import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayResult {
  final bool success;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  const RazorpayResult({required this.success, this.paymentId, this.orderId, this.signature, this.errorMessage});
}

// Wraps razorpay_flutter's event-emitter API (Razorpay.on(...)) in a single
// awaitable call - the plugin has no built-in "await the result" method, it
// only fires EVENT_PAYMENT_SUCCESS/EVENT_PAYMENT_ERROR/EVENT_EXTERNAL_WALLET
// callbacks. A dismissed checkout modal surfaces as EVENT_PAYMENT_ERROR (the
// SDK's own cancellation path), not a separate event.
class RazorpayCheckoutHelper {
  Razorpay? _razorpay;

  Future<RazorpayResult> open({
    required String keyId,
    required String razorpayOrderId,
    required int amountPaise,
    required String currency,
    required String name,
    String? description,
    String? contact,
    String? email,
    String? customerId,
  }) {
    final completer = Completer<RazorpayResult>();
    final razorpay = Razorpay();
    _razorpay = razorpay;

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      if (!completer.isCompleted) {
        completer.complete(RazorpayResult(
          success: true,
          paymentId: r.paymentId,
          orderId: r.orderId,
          signature: r.signature,
        ));
      }
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      if (!completer.isCompleted) {
        completer.complete(RazorpayResult(success: false, errorMessage: r.message ?? 'Payment failed.'));
      }
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      if (!completer.isCompleted) {
        completer.complete(RazorpayResult(success: false, errorMessage: 'Selected wallet: ${r.walletName}'));
      }
    });

    razorpay.open({
      'key': keyId,
      'order_id': razorpayOrderId,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      if (description != null) 'description': description,
      'prefill': {
        if (contact != null) 'contact': contact,
        if (email != null) 'email': email,
      },
      // customer_id both offers "save this card" (tokenizes against this
      // Razorpay customer on consent) and, on a later payment, shows any
      // cards already saved for it - see razorpay.service.js's ensureCustomer.
      if (customerId != null) 'customer_id': customerId,
      if (customerId != null) 'save': 1,
    });

    return completer.future;
  }

  void dispose() {
    _razorpay?.clear();
  }
}
