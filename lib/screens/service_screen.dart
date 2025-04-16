import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/video_background.dart';
import '../home_page.dart';
import '../services/payment_service.dart';
import 'dart:async';
import '../language/app_localizations.dart';
import '../utils/language_provider.dart';
import '../utils/inactivity_detector.dart';
import 'check_in_payment_detail.dart';

class ServiceScreen extends StatefulWidget {
  final String bookingNumber;
  final String roomNumber;

  const ServiceScreen({
    Key? key,
    required this.bookingNumber,
    required this.roomNumber,
  }) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  double _currentTotal = 0.0;
  List<Map<String, dynamic>> _serviceHistory = [];
  late AppLocalizations _localizations;
  late List<ServiceItem> _availableServices;

  @override
  void initState() {
    super.initState();
    _localizations = AppLocalizations.of(LanguageProvider.currentLanguage);
    _initializeServices();
    _loadPaymentData();
  }

  void _initializeServices() {
    _availableServices = [
      ServiceItem(
        name: _localizations.get('room_cleaning'),
        description: _localizations.get('room_cleaning_desc'),
        price: 20.0,
        icon: Icons.cleaning_services,
      ),
      ServiceItem(
        name: _localizations.get('breakfast'),
        description: _localizations.get('breakfast_desc'),
        price: 15.0,
        icon: Icons.breakfast_dining,
      ),
      ServiceItem(
        name: _localizations.get('laundry'),
        description: _localizations.get('laundry_desc'),
        price: 25.0,
        icon: Icons.local_laundry_service,
      ),

      ServiceItem(
        name: _localizations.get('spa'),
        description: _localizations.get('spa_desc'),
        price: 50.0,
        icon: Icons.spa,
      ),
      ServiceItem(
        name: _localizations.get('shuttle'),
        description: _localizations.get('shuttle_desc'),
        price: 35.0,
        icon: Icons.airport_shuttle,
      ),
      ServiceItem(
        name: _localizations.get('towels'),
        description: _localizations.get('towels_desc'),
        price: 10.0,
        icon: Icons.dry_cleaning,
      ),
    ];
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current service charges from Firebase
      _currentTotal = await _paymentService.getPaymentAmount(widget.bookingNumber);

      // Get payment history
      _serviceHistory = await _paymentService.getPaymentHistory(widget.bookingNumber);
      _serviceHistory = _serviceHistory.where((item) => item['type'] == 'service').toList();
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

  Future<void> _addService(ServiceItem service) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _paymentService.addServiceCharge(
        widget.bookingNumber,
        service.price,
        service.name,
      );

      // Reload data
      await _loadPaymentData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${service.name} added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error adding service: $e');
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

  // New method to remove a service
  Future<void> _removeService(Map<String, dynamic> serviceItem) async {
    // Show confirmation dialog
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _localizations.get('remove_service'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          _localizations.get('remove_service_confirm'),
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              _localizations.get('cancel'),
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _localizations.get('remove'),
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the document ID for this service item
      final String? docId = await _getServiceDocumentId(serviceItem);

      if (docId != null) {
        // Remove the service from Firebase
        await _paymentService.removeServiceCharge(
          widget.bookingNumber,
          docId,
          (serviceItem['amount'] as num).toDouble(),
        );

        // Reload data
        await _loadPaymentData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localizations.get('service_removed_success')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Service document not found');
      }
    } catch (e) {
      print('Error removing service: $e');
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

  // Helper method to get the document ID for a service item
  Future<String?> _getServiceDocumentId(Map<String, dynamic> serviceItem) async {
    try {
      final timestamp = serviceItem['timestamp'] as Timestamp;
      final description = serviceItem['description'] as String;
      final amount = (serviceItem['amount'] as num).toDouble();

      // Query to find the exact service document
      final querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .doc(widget.bookingNumber)
          .collection('history')
          .where('timestamp', isEqualTo: timestamp)
          .where('description', isEqualTo: description)
          .where('amount', isEqualTo: amount)
          .where('type', isEqualTo: 'service')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting service document ID: $e');
      return null;
    }
  }

  // Modified to navigate to payment screen instead of showing thank you dialog
  void _proceedToPayment() async {
    try {
      // Get booking details from Firestore
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingNumber', isEqualTo: widget.bookingNumber)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        final bookingData = bookingSnapshot.docs.first.data();
        final checkInDate = (bookingData['checkInDate'] as Timestamp).toDate();
        final checkOutDate = (bookingData['checkOutDate'] as Timestamp).toDate();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckInPaymentScreen(
              bookingNumber: widget.bookingNumber,
              roomNumber: widget.roomNumber,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              fromServiceScreen: true,
            ),
          ),
        );
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      print('Error proceeding to payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.get('error_occurred')),
          backgroundColor: Colors.red,
        ),
      );
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
                  child: Container(
                    width: 600, // Reduced width for kiosk display
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          _localizations.get('room_services_title'),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_localizations.get('room')} ${widget.roomNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Current Total Bar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _localizations.get('current_total'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              _isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Text(
                                '\$${_currentTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Services Container
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                              children: [
                                // Available Services Section
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          _localizations.get('available_services'),
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          itemCount: _availableServices.length,
                                          itemBuilder: (context, index) {
                                            final service = _availableServices[index];
                                            return ServiceItemCard(
                                              service: service,
                                              onAdd: () => _addService(service),
                                              localizations: _localizations,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Service History Section
                                if (_serviceHistory.isNotEmpty) ...[
                                  const Divider(height: 1),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            _localizations.get('service_history'),
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            itemCount: _serviceHistory.length,
                                            itemBuilder: (context, index) {
                                              final item = _serviceHistory[index];
                                              final amount = (item['amount'] as num).toDouble();
                                              final description = item['description'] as String;
                                              final timestamp = item['timestamp'] as Timestamp;
                                              final date = timestamp.toDate();

                                              return Dismissible(
                                                key: Key('${timestamp.seconds}-${timestamp.nanoseconds}'),
                                                background: Container(
                                                  color: Colors.red,
                                                  alignment: Alignment.centerRight,
                                                  padding: const EdgeInsets.only(right: 20),
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                direction: DismissDirection.endToStart,
                                                confirmDismiss: (direction) async {
                                                  return await showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text(
                                                        _localizations.get('remove_service'),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        _localizations.get('remove_service_confirm'),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(false),
                                                          child: Text(
                                                            _localizations.get('cancel'),
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(context).pop(true),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            _localizations.get('remove'),
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                onDismissed: (direction) {
                                                  _removeService(item);
                                                },
                                                child: ListTile(
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  title: Text(
                                                    description,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '\$${amount.toStringAsFixed(2)}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFFFF2D70),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () => _removeService(item),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Done Button - Changed to proceed to payment
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _proceedToPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF2D70),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _localizations.get('done'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
}

class ServiceItem {
  final String name;
  final String description;
  final double price;
  final IconData icon;

  ServiceItem({
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });
}

class ServiceItemCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onAdd;
  final AppLocalizations localizations;

  const ServiceItemCard({
    Key? key,
    required this.service,
    required this.onAdd,
    required this.localizations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D70).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                color: const Color(0xFFFF2D70),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    service.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF2D70),
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D70),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    localizations.get('add'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}