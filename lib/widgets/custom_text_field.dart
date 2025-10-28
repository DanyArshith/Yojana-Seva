import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final Icon? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.readOnly = false,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color(0xFF1E88E5),
            ),
          ),
        ),
      ),
    );
  }
}
