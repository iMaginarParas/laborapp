import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/voice_service.dart';
import 'package:flutter_app/providers/language_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;
  final List<Map<String, dynamic>> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.paleBlue,
                  child: Text("👷", style: TextStyle(fontSize: 18)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                Text(Strings.of(context, 'online'), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone_outlined, color: AppColors.primaryColor, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Privacy Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFFFFDE7),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFFFBC02D)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    Strings.of(context, 'privacy_msg'),
                    style: TextStyle(fontSize: 11, color: Colors.yellow.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg["text"], msg["isMe"], msg["time"], msg["isRead"] ?? false);
              },
            ),
          ),
          // Quick Replies
          _buildQuickReplies(),
          // Input Field
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time, bool isRead) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryColor : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                if (isMe) 
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.text,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.muted)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(isRead ? Icons.done_all : Icons.done, size: 14, color: isRead ? Colors.blue : AppColors.muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final suggestions = ["I'll be there", "Coming in 5 mins", "Address please", "Okay 👍"];
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: suggestions.map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton(
            onPressed: () {
              _controller.text = s;
              setState(() {});
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(s, style: TextStyle(color: AppColors.primaryColor, fontSize: 13)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: _isListening ? Border.all(color: AppColors.primaryColor, width: 2) : null,
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _isListening ? Strings.of(context, 'listening') : Strings.of(context, 'type_msg'),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 14, 
                      color: _isListening ? AppColors.primaryColor : Colors.grey
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCircleButton(
              onTap: () {
                if (_isListening) {
                  VoiceService.stopListening();
                  setState(() => _isListening = false);
                } else {
                  VoiceService.startListening(
                    onResult: (text) => setState(() => _controller.text = text),
                    onListeningChange: (val) => setState(() => _isListening = val),
                  );
                }
              },
              icon: _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? AppColors.primaryColor : const Color(0xFFF1F5F9),
              iconColor: _isListening ? Colors.white : AppColors.muted,
            ),
            const SizedBox(width: 8),
            _buildCircleButton(
              onTap: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _messages.add({
                      "text": _controller.text,
                      "isMe": true,
                      "time": Strings.of(context, 'just_now'),
                      "isRead": false,
                    });
                    _controller.clear();
                  });
                }
              },
              icon: Icons.send_rounded,
              color: AppColors.primaryColor,
              iconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required VoidCallback onTap, required IconData icon, required Color color, required Color iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
