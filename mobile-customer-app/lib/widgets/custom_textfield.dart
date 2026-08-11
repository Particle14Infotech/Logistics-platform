import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ported from the reference RaahMitr customer app's widgets/custom_textfield.dart.
class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLength;
  final bool obscureText;
  final List<String>? autofillHints;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength = 0,
    this.obscureText = false,
    this.autofillHints,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Starts obscured whenever the caller asked for it (password/OTP fields);
  // the eye icon below only ever un-hides it for as long as this widget is
  // on screen - there was previously no way to check what you'd actually
  // typed before submitting a login/signup form.
  late bool _obscured = widget.obscureText;

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
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength > 0 ? widget.maxLength : null,
        obscureText: _obscured,
        // Without this, a plain numeric field (like an OTP box) has no way
        // to tell Android what kind of number it expects - the keyboard's
        // own suggestion strip falls back to "recently typed numbers"
        // (phone numbers, in practice), which is both irrelevant and looks
        // broken sitting under a "6-digit code" field. The right hint also
        // lets Android surface the actual received SMS code instead.
        autofillHints: widget.autofillHints,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: Icon(widget.prefixIcon, color: Colors.grey.shade600),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(_obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade500, size: 20),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : null,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        ),
      ),
    );
  }
}
