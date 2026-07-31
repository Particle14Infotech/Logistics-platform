import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/faq_model.dart';
import '../../services/content_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _service = ContentService();
  List<FaqModel>? _faqs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final faqs = await _service.getFaqs();
      if (mounted) setState(() => _faqs = faqs);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load help content.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_outlined, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Need more help?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Email support@raahmitr.com', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Frequently asked questions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            if (_faqs == null)
              Center(child: _error != null ? Text(_error!) : const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_faqs!.isEmpty)
              Text('No FAQs available right now.', style: GoogleFonts.poppins(color: Colors.grey.shade500))
            else
              ..._faqs!.map((faq) => _FaqTile(faq: faq)),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(faq.question, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(faq.answer, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
