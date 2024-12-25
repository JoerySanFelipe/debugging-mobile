import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesScreen extends StatefulWidget {
  final List messages;
  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      itemBuilder: (context, index) {
        bool isUserMessage = widget.messages[index]['isUserMessage'];
        bool isLoading = widget.messages[index]['isLoading'] ?? false;

        return Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUserMessage)
                const Icon(Icons.flutter_dash_rounded,
                    color: Colors.green, size: 36.0),
              const SizedBox(width: 8),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                ),
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomRight: Radius.circular(isUserMessage ? 20 : 20),
                      topLeft: Radius.circular(isUserMessage ? 20 : 20),
                    ),
                    color: isUserMessage
                        ? const Color(0xFFD04848)
                        : const Color(0xFFEFEDED),
                  ),
                  constraints: BoxConstraints(maxWidth: w * 2 / 3),
                  child: _buildMessageText(widget.messages[index]['message'].text.text[0], isUserMessage),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => const Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }

  // Helper function to build message text with hyperlink support
  Widget _buildMessageText(String message, bool isUserMessage) {
    return RichText(
      text: TextSpan(
        children: _parseMessageText(message, isUserMessage),
        style: TextStyle(
          color: isUserMessage ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Helper function to detect URLs and create tappable links
  List<TextSpan> _parseMessageText(String text, bool isUserMessage) {
    final urlPattern = RegExp(
        r'((https?:\/\/)?[a-zA-Z0-9\-_]+\.[a-zA-Z]{2,}(\S*)?)');
    final words = text.split(' ');

    return words.map((word) {
      if (urlPattern.hasMatch(word)) {
        return TextSpan(
          text: '$word ',
          style: TextStyle(
            color: isUserMessage ? Colors.lightBlueAccent : Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final url = word.startsWith('http') ? word : 'https://$word';
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
        );
      } else {
        return TextSpan(text: '$word ');
      }
    }).toList();
  }
}
