import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static const String apiUrl = 'https://api.stripe.com/v1';
  static const String publishableKey = 'pk_test_51QxuV4CGkA9WhsUAkA5JNUyv72zZwSUlvJdcaGoXT9gTkGHaRc3pLpnRxlGKPFJAx6731YSvSmI6FB2VWor05XSW00w0OvQu56';
  static const String secretKey = 'sk_test_51QxuV4CGkA9WhsUAu7S88KOpPQITniiubPgejbeY23H1zQn4GNFeTqUdRaUCcKRM85CwC0aSwJ1JNd0fRxgx9sdP00dZ6tLjir';

  static Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    try {
      final url = Uri.parse('$apiUrl/payment_intents');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // Convert to cents
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  static Future<void> confirmPayment({
    required String paymentIntentClientSecret,
    required String name,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: name,
            ),
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }
}

