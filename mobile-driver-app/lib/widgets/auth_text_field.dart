import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

// Ported from the reference RaahMitr driver app's widgets/auth_text_field.dart.
class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final int maxLength;
  final bool obscureText;

  const AuthTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.maxLength = 0,
    this.obscureText = false,
    super.key,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark)),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.amber
                      : AppTheme.borderColor,
                  width: _focusNode.hasFocus ? 1.5 : 1.0),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                          color: AppTheme.amber.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : [
                      BoxShadow(
                          color: AppTheme.textDark.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength > 0 ? widget.maxLength : null,
              obscureText: widget.obscureText,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark),
              decoration: InputDecoration(
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle:
                    GoogleFonts.poppins(fontSize: 15, color: AppTheme.textGrey),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(widget.prefixIcon,
                            color: _focusNode.hasFocus
                                ? AppTheme.amber
                                : AppTheme.textGrey,
                            size: 20),
                      )
                    : null,
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
