import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import 'room_key_screen.dart';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String name;
  final String bookingNumber;
  final String roomType;
  final String stayDuration;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const BookingConfirmationScreen({
    Key? key,
    required this.name,
    required this.bookingNumber,
    required this.roomType,
    required this.stayDuration,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  _BookingConfirmationScreenState createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isUpdating = false;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
  }

  Future<void> _updateBookingStatus() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Update booking status in Firebase
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'status': 'confirmed',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Navigate to room key screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoomKeyScreen(
            bookingNumber: widget.bookingNumber,
            roomNumber: widget.roomNumber,
            checkInDate: widget.checkInDate,
            checkOutDate: widget.checkOutDate,
          ),
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.get('error_occurred')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
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
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      _localizations.get('booking_confirmation') ?? 'Booking Confirmation',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(duration: 500.ms).slide(begin: const Offset(0, -0.5)),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 400,
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(_localizations.get('name') ?? 'Name', widget.name),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('booking_number') ?? 'Booking Number', widget.bookingNumber),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('room_type') ?? 'Room Type', widget.roomType),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('room_number') ?? 'Room Number', widget.roomNumber),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('stay_duration') ?? 'Stay Duration', widget.stayDuration),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('check_in_date') ?? 'Check-in Date', _formatDate(widget.checkInDate)),
                                const SizedBox(height: 16),
                                _buildInfoRow(_localizations.get('check_out_date') ?? 'Check-out Date', _formatDate(widget.checkOutDate)),
                                const SizedBox(height: 24),
                                Center(
                                  child: Text(
                                    _localizations.get('confirm_details') ?? 'Please confirm your booking details',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: SizedBox(
                                    width: 200,
                                    child: ElevatedButton(
                                      onPressed: _isUpdating ? null : _updateBookingStatus,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF2D70),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isUpdating
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                          : Text(
                                        _localizations.get('confirm_generate_key') ?? 'Generate Room Key',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ),
        SizedBox(width: 30,),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

