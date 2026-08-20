import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

// 3-step onboarding (SRS 3.1.1). Layout matches the reference RaahMitr
// customer app's onboarding: full-bleed rounded-bottom hero area on top,
// a colored content section below with a dot indicator and a pill CTA
// button with a circular icon badge. Uses an icon-based hero (gradient +
// large icon) rather than photography, since we don't have the reference
// app's actual image assets.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<({IconData icon, String title, String body})> _slides(AppLocalizations l10n) => [
        (icon: Icons.local_shipping, title: l10n.onboardingTitle1, body: l10n.onboardingBody1),
        (icon: Icons.map, title: l10n.onboardingTitle2, body: l10n.onboardingBody2),
        (icon: Icons.payments, title: l10n.onboardingTitle3, body: l10n.onboardingBody3),
      ];

  void _next(int slideCount) {
    if (_page == slideCount - 1) {
      context.go('/login');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _slides(l10n);
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _HeroSection(icon: slides[i].icon),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
            ),
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _page ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    slides[_page].title,
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slides[_page].body,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  _GetStartedButton(
                      isLast: _page == slides.length - 1,
                      onTap: () => _next(slides.length)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final IconData icon;
  const _HeroSection({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryMedium, AppTheme.primary],
          ),
        ),
        child: Center(
            child: Icon(icon,
                size: 140, color: Colors.white.withValues(alpha: 0.9))),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;
  const _GetStartedButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(isLast ? l10n.getStarted : l10n.next,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_double_arrow_right,
                color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
