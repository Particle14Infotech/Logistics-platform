import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ported from the reference RaahMitr customer app's widgets/custom_textfield.dart.
class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLength;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength = 0,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength > 0 ? maxLength : null,
        obscureText: obscureText,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        ),
      ),
    );
  }
}
