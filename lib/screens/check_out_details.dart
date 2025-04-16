import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import 'payment_screen.dart';
import '../services/payment_service.dart';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';

class CheckoutDetailsScreen extends StatefulWidget {
  final String name;
  final String bookingNumber;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nightsStayed;
  final double roomRate;

  const CheckoutDetailsScreen({
    Key? key,
    required this.name,
    required this.bookingNumber,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nightsStayed,
    required this.roomRate,
  }) : super(key: key);

  @override
  _CheckoutDetailsScreenState createState() => _CheckoutDetailsScreenState();
}

class _CheckoutDetailsScreenState extends State<CheckoutDetailsScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  double _serviceCharges = 0.0;
  List<Map<String, dynamic>> _paymentHistory = [];
  late AppLocalizations _localizations;
  int _additionalDays = 1;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current service charges from Firebase
      _serviceCharges = await _paymentService.getPaymentAmount(widget.bookingNumber);

      // Get payment history
      _paymentHistory = await _paymentService.getPaymentHistory(widget.bookingNumber);
    } catch (e) {
      print('Error loading payment data: $e');
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

  Future<void> _confirmCheckOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update booking status to completed in Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'status': 'completed',
            'checkOutTimestamp': FieldValue.serverTimestamp(),
          });
        }
      });

      // Show success dialog
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showCheckOutSuccessDialog();
      }
    } catch (e) {
      print('Error during check-out: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localizations.get('error_occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCheckOutSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _localizations.get('check_out_successful'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _localizations.get('thank_you_for_staying'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                );
              },
              child: Text(
                _localizations.get('return_to_home'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF2D70),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLateCheckOutDialog() {
    setState(() {
      _additionalDays = 1;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                _localizations.get('extend_stay'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _localizations.get('extend_stay_message'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _additionalDays > 1
                            ? () {
                          setState(() {
                            _additionalDays--;
                          });
                        }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFFFF2D70),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_additionalDays ${_additionalDays == 1 ? _localizations.get('day') : _localizations.get('days')}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _additionalDays++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFFFF2D70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_localizations.get('total_cost')}: \$${(widget.roomRate * _additionalDays).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    _localizations.get('cancel'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _processLateCheckOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    _localizations.get('confirm'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processLateCheckOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate new check-out date
      final newCheckOutDate = widget.checkOutDate.add(Duration(days: _additionalDays));

      // Calculate payment amount
      final paymentAmount = widget.roomRate * _additionalDays;

      // Update booking in Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'checkOutDate': Timestamp.fromDate(newCheckOutDate),
            'isExtended': true,
            'extendedDays': _additionalDays,
          });
        }
      });

      // Navigate to payment screen
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              totalAmount: paymentAmount,
              bookingNumber: widget.bookingNumber,
            ),
          ),
        );

        // Record late check-out payment
        await _paymentService.addLateCheckoutCharge(
          widget.bookingNumber,
          _additionalDays,
          widget.roomRate,
        );
      }
    } catch (e) {
      print('Error processing late check-out: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localizations.get('error_occurred')),
            backgroundColor: Colors.red,
          ),
        );
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
                // Main Content
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 500,
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _localizations.get('checkout_details'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Guest Information Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(_localizations.get('name'), widget.name),
                                  _buildInfoRow(_localizations.get('booking_number'), widget.bookingNumber),
                                  _buildInfoRow(_localizations.get('room_number'), widget.roomNumber),
                                  _buildInfoRow(_localizations.get('check_in_date'), _formatDate(widget.checkInDate)),
                                  _buildInfoRow(_localizations.get('check_out_date'), _formatDate(widget.checkOutDate)),
                                  _buildInfoRow(_localizations.get('nights_stayed'), widget.nightsStayed.toString()),
                                  _buildInfoRow(_localizations.get('room_rate'), '\$${widget.roomRate.toStringAsFixed(2)}/night'),
                                ],
                              ),
                            ),

                            if (_paymentHistory.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                _localizations.get('recent_charges'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: _paymentHistory.take(3).map((item) => _buildHistoryItem(item)).toList(),
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Late Check-out Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showLateCheckOutDialog,
                                    icon: const Icon(Icons.hotel),
                                    label: Text(
                                      _localizations.get('extend_stay'),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade400,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Confirm Check-out Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _confirmCheckOut,
                                    icon: const Icon(Icons.check_circle),
                                    label: Text(
                                      _localizations.get('confirm_check_out'),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF2D70),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final amount = (item['amount'] as num).toDouble();
    final description = item['description'] as String;
    final type = item['type'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: type == 'payment' ? Colors.green : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}