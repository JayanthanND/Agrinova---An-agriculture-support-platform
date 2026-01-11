import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';

class TextInputField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const TextInputField({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: SmallTextGrey, // Apply label style
          hintStyle: NormalTextGrey,
        ),
        onChanged: onChanged,
        validator: validator,
        style: TextBlack,
      ),
    );
  }
}
