import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

// Individual boxed-digit OTP display, driven by an external numeric
// keypad (see numeric_keypad.dart) rather than the system keyboard.
// Shows 6 boxes (backend generates 6-digit codes) rather than the 4 shown
// in the reference design - kept the working backend as-is.
class OtpBoxInput extends StatelessWidget {
  final String value;
  final int length;

  const OtpBoxInput({super.key, required this.value, this.length = 6});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (i) {
        final filled = i < value.length;
        final active = i == value.length;
        return Container(
          width: 44,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? AppTheme.primary : AppTheme.borderColor, width: active ? 2 : 1),
          ),
          child: Text(
            filled ? value[i] : '',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
        );
      }),
    );
  }
}
