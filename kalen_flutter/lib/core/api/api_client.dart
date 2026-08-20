import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ApiClient _apiClient = ApiClient();

  final List<_ChatMessage> _messages = [];

  bool _isThinking = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isThinking) {
      return;
    }

    _controller.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _isThinking = true;
    });

    _scrollToBottom();

    try {
      final response = await _apiClient.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
          ),
        );

        _isThinking = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Unable to connect to KALEN backend.\n\n$e',
            isUser: false,
          ),
        );

        _isThinking = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080B0F),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.cyanAccent,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.black,
                size: 17,
              ),
            ),

            SizedBox(width: 10),

            Text(
              'KALEN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _MessageBubble(
                          message: _messages[index],
                        );
                      },
                    ),
            ),

            if (_isThinking)
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'KALEN is thinking...',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.cyanAccent,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.black,
              size: 35,
            ),
          ),

          SizedBox(height: 24),

          Text(
            'How can I help?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Ask KALEN anything.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,

              onSubmitted: (_) {
                _sendMessage();
              },

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: InputDecoration(
                hintText: 'Message KALEN...',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),

                filled: true,
                fillColor: const Color(0xFF151A20),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 700,
        ),

        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF12353D)
              : const Color(0xFF151A20),

          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Icon(
                Icons.auto_awesome,
                color: Colors.cyanAccent,
                size: 18,
              ),

              const SizedBox(width: 10),
            ],

            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}