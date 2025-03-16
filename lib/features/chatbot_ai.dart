import 'package:flutter/material.dart';
import '../headers/header_child.dart';
import '../api.dart'; // Import the API for fake chatbot reply and history

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isHistoryLoading =
      true; // New flag to show loading while retrieving history

  // Define some suggestion messages.
  final List<String> _suggestions = [
    "Chào",
    "Tôi cần trợ giúp",
    "Kết thúc cuộc trò chuyện",
    "Cảm ơn"
  ];

  // Instance variable for adjusted top padding.
  double _adjustedTopPadding = 12;

  @override
  void initState() {
    super.initState();
    _loadHistoryMessages();
  }

  Future<void> _loadHistoryMessages() async {
    final history = await Api.getHistoryMessage();
    setState(() {
      _messages.addAll(history.map((item) => ChatMessage(
            text: item["text"],
            isUser: item["isUser"],
            timestamp: DateTime.parse(item["timestamp"]),
          )));
      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isHistoryLoading = false; // Finished loading history
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double topPadding = MediaQuery.of(context).padding.top;
    setState(() {
      _adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;
    });
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    if (text == 'Kết thúc cuộc trò chuyện') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kết thúc cuộc trò chuyện'),
            content:
                const Text('Bạn có chắc chắn muốn kết thúc cuộc trò chuyện?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  await Api.clearMessage();
                  setState(() {
                    _messages.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Xác nhận'),
              ),
            ],
          );
        },
      );
      _controller.clear();
      return;
    }

    final now = DateTime.now();
    setState(() {
      _messages.insert(
          0, ChatMessage(text: text, isUser: true, timestamp: now));
    });
    _controller.clear();

    // Add a temporary bot message with a loading animation.
    final botLoadingMessage = ChatMessage(
      text: "",
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    setState(() {
      _messages.insert(0, botLoadingMessage);
    });

    Api.getChatbotReply(text).then((reply) {
      setState(() {
        final index = _messages.indexWhere((m) => m == botLoadingMessage);
        if (index != -1) {
          _messages[index] = ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          );
        }
      });
    });
  }

  void _handleSend() {
    _sendMessage(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderChild(title: "Trợ lý AI"),
          Expanded(
            child: Column(
              children: [
                // Message list or loading indicator
                Expanded(
                  child: _isHistoryLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              DotLoadingAnimation(),
                              SizedBox(height: 8),
                              Text(
                                "Đang tải lịch sử cuộc trò chuyện...",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _messages.isEmpty
                          ? Center(
                              child: Text(
                                "Start the conversation...",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                final timeString =
                                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";
                                final avatarImage = message.isUser
                                    ? 'assets/images/user.png'
                                    : 'assets/images/chatbot.png';

                                return Row(
                                  mainAxisAlignment: message.isUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!message.isUser) ...[
                                      CircleAvatar(
                                        backgroundImage:
                                            AssetImage(avatarImage),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: message.isUser
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 14),
                                            decoration: BoxDecoration(
                                              color: message.isUser
                                                  ? Colors.blueAccent
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: message.isLoading
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: const [
                                                      DotLoadingAnimation(),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Đang trả lời...",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    message.text,
                                                    style: TextStyle(
                                                      color: message.isUser
                                                          ? Colors.white
                                                          : Colors.black87,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Text(
                                              timeString,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (message.isUser) ...[
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        backgroundImage:
                                            AssetImage(avatarImage),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                ),
                // Suggestion chips
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestions.map((suggestion) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(suggestion),
                            onPressed: () {
                              _sendMessage(suggestion);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Input field
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF2F3D85),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _handleSend,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });
}

/// A custom widget that displays three dots that animate up and down.
class DotLoadingAnimation extends StatefulWidget {
  const DotLoadingAnimation({Key? key}) : super(key: key);

  @override
  _DotLoadingAnimationState createState() => _DotLoadingAnimationState();
}

class _DotLoadingAnimationState extends State<DotLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this)
      ..repeat();
    _animation1 = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_animation1),
        _buildDot(_animation2),
        _buildDot(_animation3),
      ],
    );
  }
}
