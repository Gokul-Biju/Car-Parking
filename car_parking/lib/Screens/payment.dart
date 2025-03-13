import 'package:car_parking/Firebase/Firebase_parking.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment {
  final int price;
  final String? parkingId;
  final String? slotId;
  final int slotindex;
  final int availableIndex;
  final DateTime bookingStartTime;
  final DateTime bookingEndTime;
  final String vehicle;
  BuildContext context;
  final Function(bool) setLoading;

  Payment({
    required this.price,
    required this.parkingId,
    required this.slotId,
    required this.slotindex,
    required this.availableIndex,
    required this.vehicle,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.context,
    required this.setLoading,
  });

  void _bookSlot() async {
    final _parkingData = AddParkingData();
    try {
      await _parkingData.updateSlotAvailability(
        parkingId,
        slotId,
        availableIndex,
        bookingStartTime,
        bookingEndTime,
        slotindex,
        vehicle,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Slot booked successfully!"),
          margin: EdgeInsets.all(5),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error booking slot: $e"),
          margin: EdgeInsets.all(5),
          elevation: 10,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> onPayment()async {
    Razorpay razorpay = Razorpay();
    var options = {
      'key': 'rzp_test_QECw6lqG3ljlZk',
      'amount': price * 100,
      'name': 'Acme Corp.',
      'description': 'Parking Booking',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8281863142', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm'],
      },
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(
      context,
      "Payment Failed",
      "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}",
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    try {
      setLoading(true);
      _bookSlot();
      await showAlertDialog(
        context,
        "Payment Successful",
        "Payment ID: ${response.paymentId}",
      );
    } finally {
      setLoading(false);
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
      context,
      "External Wallet Selected",
      "${response.walletName}",
    );
  }

  Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    AlertDialog alert = AlertDialog(title: Text(title), content: Text(message));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}