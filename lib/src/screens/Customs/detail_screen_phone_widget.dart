import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneNumberField extends StatelessWidget {
  final String label;
  final String phoneNumber;

  const PhoneNumberField({
    Key? key,
    required this.label,
    required this.phoneNumber,
  }) : super(key: key);

  // Method to launch the phone app
  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    // Format the number to include country code if missing
    final String sanitizedNumber = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+91$phoneNumber'; // Replace '+91' with your country code
    final Uri url = Uri(scheme: 'tel', path: sanitizedNumber);
    final _call = 'tel:$sanitizedNumber';
    debugPrint('Trying to launch $url');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone app'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow effect
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label and phone number display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SmallTextGrey, // Label style
              ),
              const SizedBox(height: 5),
              Text(
                phoneNumber,
                style: TextBlack, // Display phone number in black
              ),
            ],
          ),
          // Phone icon button
          IconButton(
            onPressed: () => _makePhoneCall(context, phoneNumber),
            icon: Icon(
              Icons.phone,
              color: Colors.green, // Phone icon color
            ),
          ),
        ],
      ),
    );
  }
}
