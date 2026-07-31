import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/socket_service.dart';

// In-trip chat with the assigned driver - previously the chat icon on the
// booking detail screen was a no-op. Real-time delivery via the same
// Socket.IO booking room already used for live tracking; REST history
// backs the initial load / catching up on messages sent while this
// screen wasn't open.
class ChatScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String? driverName;
  const ChatScreen({super.key, required this.bookingId, this.driverName});

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
    _socketService.leaveBookingRoom(widget.bookingId);
    _socketService.dispose();
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
      if (mounted) setState(() => _error = 'Could not load messages.');
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
    _socketService.sendChatMessage(widget.bookingId, text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(widget.driverName ?? 'Chat with driver')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages == null
                  ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
                  : _messages!.isEmpty
                      ? Center(
                          child: Text('Say hello to your driver.',
                              style: GoogleFonts.poppins(color: Colors.grey.shade500)))
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
                          hintText: 'Type a message…',
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
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
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
    final isMe = message.senderRole == 'customer';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 13.5),
        ),
      ),
    );
  }
}
