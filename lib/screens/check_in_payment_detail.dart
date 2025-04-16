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

class CheckInPaymentScreen extends StatefulWidget {
  final String bookingNumber;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final bool fromServiceScreen;

  const CheckInPaymentScreen({
    Key? key,
    required this.bookingNumber,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    this.fromServiceScreen = false,
  }) : super(key: key);

  @override
  _CheckInPaymentScreenState createState() => _CheckInPaymentScreenState();
}

class _CheckInPaymentScreenState extends State<CheckInPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  double _roomRate = 100.0; // Default room rate
  double _serviceCharges = 0.0;
  double _totalPayment = 0.0;
  int _nightsStayed = 1;
  List<Map<String, dynamic>> _serviceHistory = [];
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
    _loadBookingAndPaymentData();
  }

  Future<void> _loadBookingAndPaymentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _nightsStayed = widget.checkOutDate.difference(widget.checkInDate).inDays;
      if (_nightsStayed < 1) _nightsStayed = 1;

      // First try to get room rate from the booking document
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        final bookingData = bookingSnapshot.docs.first.data();
        // Check if roomRate exists in the document and is not null
        if (bookingData.containsKey('roomRate') && bookingData['roomRate'] != null) {
          // Convert to double regardless of whether it's stored as int or double
          _roomRate = (bookingData['roomRate'] is int)
              ? (bookingData['roomRate'] as int).toDouble()
              : (bookingData['roomRate'] as num).toDouble();

          print('Room rate from Firebase: $_roomRate');
        } else {
          print('Room rate not found in Firebase, using default: $_roomRate');
        }
      } else {
        print('Booking not found, using default room rate: $_roomRate');
      }

      // Get service charges
      _serviceCharges = await _paymentService.getPaymentAmount(widget.bookingNumber);

      // Get service history
      _serviceHistory = await _paymentService.getPaymentHistory(widget.bookingNumber);
      _serviceHistory = _serviceHistory.where((item) => item['type'] == 'service').toList();

      // Calculate total payment
      final roomCharge = _nightsStayed * _roomRate;
      _totalPayment = roomCharge + _serviceCharges;

      // If coming from room key screen (not service screen), add room charge
      if (!widget.fromServiceScreen) {
        await _paymentService.addRoomCharge(widget.bookingNumber, _nightsStayed, _roomRate);
        // Refresh service charges after adding room charge
        _serviceCharges = await _paymentService.getPaymentAmount(widget.bookingNumber);
        _totalPayment = _serviceCharges; // Total is now just the service charges (which includes room charge)
      }
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

  void _proceedToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          totalAmount: _totalPayment,
          bookingNumber: widget.bookingNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomCharge = _nightsStayed * _roomRate;

    return InactivityDetector(
      child: Scaffold(
        body: VideoBackground(
          videoAsset: 'assets/bgvideo.mp4',
          child: SafeArea(
            child: Stack(
              children: [
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
                    ),
                  ),
                ),
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
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.fromServiceScreen
                                  ? _localizations.get('service_payment')
                                  : _localizations.get('check_in_payment'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(_localizations.get('room_number'), widget.roomNumber),
                            _buildInfoRow(_localizations.get('check_in_date'), _formatDate(widget.checkInDate)),
                            _buildInfoRow(_localizations.get('check_out_date'), _formatDate(widget.checkOutDate)),
                            _buildInfoRow(_localizations.get('nights_stayed'), _nightsStayed.toString()),
                            _buildInfoRow(_localizations.get('room_rate'), '\$${_roomRate.toStringAsFixed(2)}/night'),

                            // Show room charge
                            _buildInfoRow(_localizations.get('room_charge'), '\$${roomCharge.toStringAsFixed(2)}'),

                            // Show service charges if any
                            if (_serviceHistory.isNotEmpty)
                              _buildInfoRow(_localizations.get('service_charges'), '\$${(_serviceCharges - roomCharge).toStringAsFixed(2)}'),

                            const SizedBox(height: 24),
                            _buildInfoRow(_localizations.get('total_payment'), '\$${_totalPayment.toStringAsFixed(2)}', isTotal: true),

                            // Show service details if any
                            if (_serviceHistory.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                _localizations.get('service_details'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(_serviceHistory.length, (index) {
                                final service = _serviceHistory[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        service['description'] as String,
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        '\$${((service['amount'] as num).toDouble()).toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            const SizedBox(height: 32),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _proceedToPayment,
                                icon: const Icon(Icons.payment),
                                label: Text(
                                  _localizations.get('proceed_to_payment'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF2D70),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
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

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
          Text(
            value,
            style: GoogleFonts.poppins(
                fontSize: isTotal ? 18 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFFFF2D70) : Colors.black87
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