import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class SentMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final IconData tickIcon;
  final Color tickColor;

  SentMessageBubble({
    required this.message,
    required this.time,
    required this.tickIcon,
    required this.tickColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 50, right: 10, top: 5, bottom: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF075E54), // WhatsApp green for sent messages
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(2), // Small tail for sender
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: 12), // Space for time & ticks
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 12,
            child: Row(
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                SizedBox(width: 4),
                Icon(tickIcon, size: 12, color: tickColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReceivedMessageBubble extends StatelessWidget {
  final String message;
  final String time;

  ReceivedMessageBubble({
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10, right: 50, top: 5, bottom: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300], // Light grey for received messages
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(2), // Small tail for receiver
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: 12), // Space for time
              child: Text(
                message,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 12,
            child: Text(
              time,
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
