import 'package:flutter/material.dart';
import '../headers/header_child.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  // Instance variable for adjusted top padding.
  double _adjustedTopPadding = 12;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the top padding from MediaQuery.
    final double topPadding = MediaQuery.of(context).padding.top;
    // Compute the adjusted top padding: if topPadding is greater than 26, subtract 26; otherwise default to 12.
    setState(() {
      _adjustedTopPadding = topPadding > 26 ? topPadding - 26 : 12;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      // Add user message (insert at beginning for reverse order)
      _messages.insert(0, ChatMessage(text: text, isUser: true));
    });
    _controller.clear();

    // Simulate a chatbot reply after a delay.
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(text: "This is a simulated reply.", isUser: false),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar; we now use a custom header.
      body: Column(
        children: [
          const HeaderChild(
            title: "Trợ lý AI",
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
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
                            return Align(
                              alignment: message.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: message.isUser
                                      ? Colors.blueAccent
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
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
  ChatMessage({required this.text, required this.isUser});
}
