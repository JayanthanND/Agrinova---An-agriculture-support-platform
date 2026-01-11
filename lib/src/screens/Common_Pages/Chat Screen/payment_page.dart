import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_app.dart';
import 'package:upi_india/upi_india.dart';
import 'package:uuid/uuid.dart';

class PaymentPage extends StatefulWidget {
  final String senderId;
  final String senderCollection;
  final String recieverId;
  final String recieverCollection;
  final String receiverName;
  final String receiverProfile;
  final String receiverUpiId;

  const PaymentPage({
    Key? key,
    required this.senderId,
    required this.senderCollection,
    required this.recieverId,
    required this.recieverCollection,
    required this.receiverName,
    required this.receiverProfile,
    required this.receiverUpiId,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receiver Details
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.receiverProfile),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.receiverUpiId,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Amount Input Field
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Next Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter an amount")),
                    );
                  } else {
                    double amount = double.parse(_amountController.text);
                    _initiateUPIPayment(context, amount);
                  }
                },
                child: Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateUPIPayment(BuildContext context, double amount) async {
    final UpiIndia _upiIndia = UpiIndia();

    // Fetch sender's UPI ID
    DocumentSnapshot senderDoc = await _firestore
        .collection(widget.senderCollection)
        .doc(widget.senderId)
        .get();
    String senderUpiId = senderDoc['upiId'] ?? '';

    if (senderUpiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sender's UPI ID not found!")),
      );
      return;
    }
    UpiApp _getUpiAppFromUpiId(String upiId) {
      if (upiId.endsWith('@okaxis')) {
        return UpiApp.phonePe;
      } else if (upiId.endsWith('@okhdfcbank')) {
        return UpiApp.googlePay;
      } else if (upiId.endsWith('@ptyes')) {
        return UpiApp.paytm;
      } else {
        return UpiApp.allBank; // Fallback to all UPI apps
      }
    }

    // Determine the UPI app based on the sender's UPI ID
    UpiApp upiApp = _getUpiAppFromUpiId(senderUpiId);

    // Initiate UPI payment
    UpiResponse response = await _upiIndia.startTransaction(
      app: upiApp, // Use the selected UPI app
      receiverUpiId: widget.receiverUpiId, // Receiver's UPI ID
      receiverName: widget.receiverName, // Receiver's name
      transactionRefId:
          'TXN${DateTime.now().millisecondsSinceEpoch}', // Unique transaction ID
      transactionNote: 'Payment to ${widget.receiverName}', // Payment note
      amount: amount, // Amount to pay
    );

    // Handle payment response
    if (response.status == UpiPaymentStatus.SUCCESS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment successful!")),
      );
      _sendPaymentMessage(amount); // Send payment confirmation message
      Navigator.pop(context); // Return to chat screen
    } else if (response.status == UpiPaymentStatus.FAILURE) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: ${response}")),
      );
    } else if (response.status == UpiPaymentStatus.SUBMITTED) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment submitted")),
      );
    }
  }

  Future<void> _sendPaymentMessage(double amount) async {
    String messageId = const Uuid().v4();

    String senderPath =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.recieverId}/chats/$messageId';
    String receiverPath =
        '${widget.recieverCollection}/${widget.recieverId}/messages/${widget.senderId}/chats/$messageId';

    // Structured payment message
    Map<String, dynamic> paymentMessage = {
      'senderId': widget.senderId,
      'receiverId': widget.recieverId,
      'message': 'Payment of ₹$amount completed!',
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'isRead': false,
      'isPayment': true, // Flag to identify payment messages
      'paymentAmount': amount, // Store the payment amount
      'paymentStatus': 'completed', // Payment status
    };

    try {
      await _firestore.doc(senderPath).set(paymentMessage);
      await _firestore.doc(receiverPath).set(paymentMessage);
      print("Payment message sent with ID: $messageId");
    } catch (e) {
      print("Error sending payment message: $e");
    }
  }
}
