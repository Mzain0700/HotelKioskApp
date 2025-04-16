import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import 'service_screen.dart';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';
import 'check_in_payment_detail.dart';

class RoomKeyScreen extends StatefulWidget {
  final String bookingNumber;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const RoomKeyScreen({
    Key? key,
    required this.bookingNumber,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  _RoomKeyScreenState createState() => _RoomKeyScreenState();
}

class _RoomKeyScreenState extends State<RoomKeyScreen> {
  String? _qrData;
  bool _isLoading = true;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
    _generateAndStoreQRCode();
  }

  Future<void> _generateAndStoreQRCode() async {
    final uuid = Uuid();
    final uniqueKey = uuid.v4();
    final qrData = 'ROOM:${widget.roomNumber}|KEY:$uniqueKey|BOOKING:${widget.bookingNumber}';

    try {
      await FirebaseFirestore.instance
          .collection('room_keys')
          .doc(widget.bookingNumber)
          .set({
        'roomNumber': widget.roomNumber,
        'keyData': qrData,
        'checkInDate': widget.checkInDate,
        'checkOutDate': widget.checkOutDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _qrData = qrData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error storing QR code data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _proceedToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckInPaymentScreen(
          bookingNumber: widget.bookingNumber,
          roomNumber: widget.roomNumber,
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      child: Scaffold(
        body: VideoBackground(
          videoAsset: 'assets/bgvideo.mp4',
          child: SafeArea(
            child: Center(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(24.0),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _localizations.get('your_room_key'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_localizations.get('room')} ${widget.roomNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_qrData != null)
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 200.0,
                      )
                    else
                      Text(
                        _localizations.get('error_generating_qr'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _localizations.get('scan_qr'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_localizations.get('valid')} ${_formatDate(widget.checkInDate)} - ${_formatDate(widget.checkOutDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        _localizations.get('done'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ServiceScreen(
                              bookingNumber: widget.bookingNumber,
                              roomNumber: widget.roomNumber,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        _localizations.get('request_services'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
