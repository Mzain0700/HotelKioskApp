import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current payment amount for a booking
  Future<double> getPaymentAmount(String bookingNumber) async {
    try {
      final paymentDoc = await _firestore
          .collection('payments')
          .doc(bookingNumber)
          .get();

      if (paymentDoc.exists) {
        return (paymentDoc.data()?['amount'] as num?)?.toDouble() ?? 0.0;
      } else {
        // Initialize payment record if it doesn't exist
        await _firestore.collection('payments').doc(bookingNumber).set({
          'amount': 0.0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return 0.0;
      }
    } catch (e) {
      print('Error getting payment amount: $e');
      return 0.0;
    }
  }

  // Add a service charge to the existing payment amount
  Future<void> addServiceCharge(String bookingNumber, double amount, String description) async {
    try {
      // Get current amount
      final currentAmount = await getPaymentAmount(bookingNumber);
      final newAmount = currentAmount + amount;

      // Update payment record
      await _firestore.collection('payments').doc(bookingNumber).set({
        'amount': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to payment history
      await _firestore.collection('payments').doc(bookingNumber)
          .collection('history').add({
        'amount': amount,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'service',
      });
    } catch (e) {
      print('Error adding service charge: $e');
      throw Exception('Failed to add service charge: $e');
    }
  }

  // Remove a service charge
  Future<void> removeServiceCharge(String bookingNumber, String serviceDocId, double amount) async {
    try {
      // Get current amount
      final currentAmount = await getPaymentAmount(bookingNumber);
      final newAmount = currentAmount - amount;

      // Update payment record with reduced amount
      await _firestore.collection('payments').doc(bookingNumber).set({
        'amount': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Delete the service from history
      await _firestore.collection('payments')
          .doc(bookingNumber)
          .collection('history')
          .doc(serviceDocId)
          .delete();
    } catch (e) {
      print('Error removing service charge: $e');
      throw Exception('Failed to remove service charge: $e');
    }
  }

  // Add room charge based on nights stayed and room rate
  Future<void> addRoomCharge(String bookingNumber, int nightsStayed, double roomRate) async {
    try {
      final roomCharge = nightsStayed * roomRate;

      // Get current amount
      final currentAmount = await getPaymentAmount(bookingNumber);
      final newAmount = currentAmount + roomCharge;

      // Update payment record
      await _firestore.collection('payments').doc(bookingNumber).set({
        'amount': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to payment history
      await _firestore.collection('payments').doc(bookingNumber)
          .collection('history').add({
        'amount': roomCharge,
        'description': 'Room charge for $nightsStayed nights at \$${roomRate.toStringAsFixed(2)}/night',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'room',
      });
    } catch (e) {
      print('Error adding room charge: $e');
      throw Exception('Failed to add room charge: $e');
    }
  }

  // Add late checkout charge
  Future<void> addLateCheckoutCharge(String bookingNumber, int additionalNights, double roomRate) async {
    try {
      final lateCheckoutCharge = additionalNights * roomRate;

      // Get current amount
      final currentAmount = await getPaymentAmount(bookingNumber);
      final newAmount = currentAmount + lateCheckoutCharge;

      // Update payment record
      await _firestore.collection('payments').doc(bookingNumber).set({
        'amount': newAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to payment history
      await _firestore.collection('payments').doc(bookingNumber)
          .collection('history').add({
        'amount': lateCheckoutCharge,
        'description': 'Late checkout charge for $additionalNights additional ${additionalNights == 1 ? "night" : "nights"} at \$${roomRate.toStringAsFixed(2)}/night',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'late_checkout',
      });
    } catch (e) {
      print('Error adding late checkout charge: $e');
      throw Exception('Failed to add late checkout charge: $e');
    }
  }

  // Record a payment transaction
  Future<void> recordPayment(String bookingNumber, double amount) async {
    try {
      // Reset the payment amount to 0 after payment
      await _firestore.collection('payments').doc(bookingNumber).set({
        'amount': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastPaymentAmount': amount,
        'lastPaymentDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Add to payment history
      await _firestore.collection('payments').doc(bookingNumber)
          .collection('history').add({
        'amount': amount,
        'description': 'Payment received',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'payment',
      });
    } catch (e) {
      print('Error recording payment: $e');
      throw Exception('Failed to record payment: $e');
    }
  }

  // Get payment history for a booking
  Future<List<Map<String, dynamic>>> getPaymentHistory(String bookingNumber) async {
    try {
      final historySnapshot = await _firestore
          .collection('payments')
          .doc(bookingNumber)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      return historySnapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID to the data map
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }
}