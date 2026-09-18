import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class RazorpayService {
  late Razorpay _razorpay;
  
  // Callbacks for UI to listen to
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService({
    this.onSuccess,
    this.onFailure,
    this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Send to backend for verification
    try {
      final verifyResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments/verify'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${ApiConfig.token}', // TODO: Add auth token here
        },
        body: jsonEncode({
          'razorpay_payment_id': response.paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_signature': response.signature,
        }),
      );

      if (verifyResponse.statusCode == 200) {
        if (onSuccess != null) {
          onSuccess!(response);
        }
      } else {
        // Could trigger onFailure here instead if backend fails
      }
    } catch (e) {
      // Handle error implicitly or log using standard tools later
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  Future<void> openCheckout({
    required int amountInSmallestCurrency, // e.g. paise for INR
    required String name,
    required String description,
    required String contact,
    required String email,
    String currency = 'INR',
  }) async {
    try {
      // 1. Create order on backend
      final orderResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payments/create-order'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${ApiConfig.token}', // TODO: Add auth token here
        },
        body: jsonEncode({
          'amount': amountInSmallestCurrency,
          'currency': currency,
        }),
      );

      if (orderResponse.statusCode == 200) {
        final orderData = jsonDecode(orderResponse.body)['data'];
        final orderId = orderData['id'];
        final keyId = orderData['key_id'];

        // 2. Open Razorpay Checkout
        var options = {
          'key': keyId,
          'amount': amountInSmallestCurrency,
          'name': name,
          'description': description,
          'order_id': orderId,
          'prefill': {
            'contact': contact,
            'email': email
          },
          'theme': {
            'color': '#FF3366' // Match app branding
          }
        };

        _razorpay.open(options);
      } else {
        throw Exception('Failed to create order on backend: ${orderResponse.body}');
      }
    } catch (e) {
      print('Error opening checkout: $e');
      if (onFailure != null) {
        // Construct a generic error response
        // Note: You might need to handle this differently based on UI needs
      }
    }
  }
}
