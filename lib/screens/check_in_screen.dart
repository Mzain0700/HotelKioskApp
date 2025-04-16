import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import 'booking_confirmation_screen.dart';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _surnameController = TextEditingController();
  final _bookingNumberController = TextEditingController();
  bool _isLoading = false;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _surnameController.addListener(_updateButtonState);
    _bookingNumberController.addListener(_updateButtonState);
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _fieldsAreFilled =>
      _surnameController.text.isNotEmpty && _bookingNumberController.text.isNotEmpty;

  Future<void> _validateBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('surname', isEqualTo: _surnameController.text.trim())
          .where('bookingNumber', isEqualTo: _bookingNumberController.text.trim())
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        final bookingData = bookingSnapshot.docs.first.data();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              name: bookingData['guestName'],
              bookingNumber: bookingData['bookingNumber'],
              roomType: bookingData['roomType'],
              stayDuration: '${bookingData['nights']} nights',
              roomNumber: bookingData['roomNumber'],
              checkInDate: (bookingData['checkInDate'] as Timestamp).toDate(),
              checkOutDate: (bookingData['checkOutDate'] as Timestamp).toDate(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localizations.get('invalid_booking')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error validating booking: $e');
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

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        body: VideoBackground(
          videoAsset: 'assets/bgvideo.mp4',
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
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
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
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _localizations.get('self_check_in'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _localizations.get('surname'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 300,
                        height: 40,
                        child: TextField(
                          controller: _surnameController,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: _localizations.get('enter_surname'),
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.black38,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      Text(
                        _localizations.get('booking_number'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 300,
                        height: 40,
                        child: TextField(
                          controller: _bookingNumberController,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: _localizations.get('enter_booking_number'),
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.black38,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      Center(
                        child: SizedBox(
                          width: 160,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _fieldsAreFilled && !_isLoading ? _validateBooking : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2D70),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              _localizations.get('continue'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _bookingNumberController.dispose();
    super.dispose();
  }
}

