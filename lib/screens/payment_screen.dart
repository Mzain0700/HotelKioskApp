import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import 'payment_success_screen.dart';
import '../services/payment_service.dart';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String bookingNumber;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.bookingNumber,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardHolderController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  CardFieldInputDetails? _card;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
  }

  Future<void> _handlePayment() async {
    if (_card == null || !_card!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.get('error_occurred')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_cardHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.get('error_occurred')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create payment intent on the server
      final paymentIntentResult = await _createPaymentIntent();

      if (paymentIntentResult == null || paymentIntentResult['client_secret'] == null) {
        throw Exception('Failed to create payment intent');
      }

      // Confirm payment with Stripe SDK
      await _confirmPayment(paymentIntentResult['client_secret']);

      // Record payment in Firebase
      await _paymentService.recordPayment(widget.bookingNumber, widget.totalAmount);

      // Update booking status to "completed"
      await _updateBookingStatus();

      // Navigate to success screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: widget.totalAmount,
            bookingNumber: widget.bookingNumber,
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.get('error_occurred')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBookingStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'status': 'completed',
            'checkoutDate': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating booking status: $e');
      // Don't throw here, as we still want to show the payment success screen
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent() async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer sk_test_51QxuV4CGkA9WhsUAu7S88KOpPQITniiubPgejbeY23H1zQn4GNFeTqUdRaUCcKRM85CwC0aSwJ1JNd0fRxgx9sdP00dZ6tLjir',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': (widget.totalAmount * 100).toInt().toString(), // Convert to cents
          'currency': 'usd',
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error ${response.statusCode}: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  Future<void> _confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _cardHolderController.text,
            ),
          ),
        ),
      );
    } catch (e) {
      if (e is StripeException) {
        throw Exception('Stripe error: ${e.error.localizedMessage}');
      } else {
        throw Exception('An unexpected error occurred');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        body: VideoBackground(
          videoAsset: 'assets/bgvideo.mp4',
          child: SafeArea(
            child: Stack(
              children: [
                // Home Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                      ),
                      icon: const Icon(Icons.home, color: Colors.white, size: 20),
                      label: Text(
                        _localizations.get('home_page'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 450,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                      // padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _localizations.get('payment_title'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_localizations.get('total_amount')} \$${widget.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF2D70),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              _localizations.get('card_information'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CardField(
                              onCardChanged: (card) {
                                setState(() {
                                  _card = card;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF2D70),
                                    width: 2,
                                  ),
                                ),
                                hintText: _localizations.get('enter_card_details'),
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _localizations.get('cardholder_name'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _cardHolderController,
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: _localizations.get('enter_cardholder'),
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF2D70),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handlePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF2D70),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  '${_localizations.get('pay')} \$${widget.totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                _localizations.get('payment_secure'),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 5),
                                  Text(
                                    _localizations.get('secured_by'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    super.dispose();
  }
}

