import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

// Ported from the reference RaahMitr driver app's widgets/auth_button.dart -
// gradient pill button with a subtle press-scale animation.
class AuthButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;

  const AuthButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 62,
    super.key,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _scaleController.forward(),
      onTapUp: widget.isLoading ? null : (_) => _scaleController.reverse(),
      onTapCancel: widget.isLoading ? null : () => _scaleController.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.98).animate(
            CurvedAnimation(parent: _scaleController, curve: Curves.easeOut)),
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.amberLight, AppTheme.amber, Color(0xFFE6A800)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.amber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
              BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(-2, -2)),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textDark.withValues(alpha: 0.7))),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        letterSpacing: 0.5),
                  ),
          ),
        ),
      ),
    );
  }
}
