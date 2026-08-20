import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';

// In-trip chat with the customer - previously the chat icon on the active
// trip screen was a no-op. Real-time delivery over the same Socket.IO
// booking room already used for live tracking; REST history backs the
// initial load / catching up on messages sent while this screen wasn't
// open. Shares the exact backend already built for the customer app's
// chat screen.
class ChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String? customerName;
  const ChatScreen({super.key, required this.bookingId, this.customerName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _chatService = ChatService();
  final _socketService = SocketService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage>? _messages;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _connect();
  }

  @override
  void dispose() {
    // Don't dispose the socket here - it's a shared singleton and the
    // Active Trip screen underneath this one still needs it connected
    // for live GPS broadcast.
    _socketService.leaveBookingRoom(widget.bookingId);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final messages = await _chatService.getHistory(widget.bookingId);
      if (mounted) {
        setState(() => _messages = messages);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.couldNotLoadMessages);
    }
  }

  void _connect() {
    final accessToken = ref.read(authProvider).accessToken;
    if (accessToken == null) return;
    _socketService.connect(accessToken);
    _socketService.joinBookingRoom(widget.bookingId);
    _socketService.onChatMessage((data) {
      if (!mounted) return;
      setState(() => _messages = [...?_messages, ChatMessage.fromJson(data)]);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (!_socketService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.notConnectedCouldNotSendMessage)),
      );
      return;
    }
    _socketService.sendChatMessage(widget.bookingId, text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: Text(widget.customerName ?? l10n.chatWithCustomer)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages == null
                  ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
                  : _messages!.isEmpty
                      ? Center(
                          child: Text(l10n.sayHelloToYourCustomer,
                              style: GoogleFonts.poppins(color: AppTheme.textGrey)))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages!.length,
                          itemBuilder: (context, i) => _MessageBubble(message: _messages![i]),
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: l10n.typeAMessageHint,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderRole == 'driver';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.amber : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(color: isMe ? Colors.black87 : AppTheme.textDark, fontSize: 13.5),
        ),
      ),
    );
  }
}
