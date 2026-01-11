import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../Language/app_localization.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatBot> {
  final FlutterTts flutterTts = FlutterTts();

  final TextEditingController _userInput = TextEditingController();
  static const apiKey =
      "AIzaSyB4Vq8FWoA8ipSTD_zuXLvao3TPafikVTo"; // Replace with your actual API key
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    HapticFeedback.lightImpact();
    _userInput.clear(); // Clear input immediately

    Future.delayed(const Duration(milliseconds: 200), () {
      FocusScope.of(context).unfocus(); // Smoothly hide the keyboard
    });

    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
      _messages.add(Message(
          isUser: false,
          message: "Analyzing...",
          date: DateTime.now(),
          isTyping: true));
    });

    final content = [Content.text(message)];
    try {
      final response = await model.generateContent(content);

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _messages.removeLast(); // Remove "Analyzing..."
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Error: No response from AI",
          date: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(Message(
          isUser: false,
          message: "Error: Unable to get response - $e",
          date: DateTime.now(),
        ));
      });
    }
  }

  Map<String, bool> _speakingMessages =
      {}; // Track speaking state for each message

  Future<void> _speakTamil(String message) async {
    if (_speakingMessages[message] == true) {
      await flutterTts.stop(); // Stop only if this message is speaking
      setState(() {
        _speakingMessages[message] = false;
      });
      return;
    }

    String cleanedMessage = message.replaceAll(RegExp(r'[*•-]'), '');
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);

    setState(() {
      _speakingMessages[message] = true; // Mark this message as speaking
    });

    await flutterTts.speak(cleanedMessage);

    flutterTts.setCompletionHandler(() {
      setState(() {
        _speakingMessages[message] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.watch<LocalizationService>().translate("chatTitle"),
          style: NormalTextWhite,
        ),
        centerTitle: true,
        backgroundColor: MainGreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.white), // Custom back arrow
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/images/chat_bg.jpg'), // Add your image in assets
              fit: BoxFit.cover,
              opacity: 0.4 // Covers the entire screen
              ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        context
                            .watch<LocalizationService>()
                            .translate("askMeAnything"),
                        style: NormalTextGrey,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];

                        return SlideTransitionMessage(
                          child: message.isTyping
                              ? const TypingIndicator()
                              : ChatBubble(
                                  isUser: message.isUser,
                                  message: message.message,
                                  time: DateFormat('hh:mm a')
                                      .format(message.date),
                                  onPlayAudio: _speakTamil,
                                  speakingMessages:
                                      _speakingMessages, // ✅ Pass this
                                ),
                        );
                      },
                    ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _userInput,
              decoration: InputDecoration(
                hintText: context
                    .watch<LocalizationService>()
                    .translate("typeMessage"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: MainGreen,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTyping;

  Message(
      {required this.isUser,
      required this.message,
      required this.date,
      this.isTyping = false});
}

/// Chat Bubble Widget with AI Avatar
class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String time;
  final Function(String)? onPlayAudio; // Accepts a function to handle speech
  final FlutterTts flutterTts = FlutterTts();
  final Map<String, bool> speakingMessages;

  ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.time,
    this.onPlayAudio, // Nullable function parameter
    required this.speakingMessages,
  });

  @override
  Widget build(BuildContext context) {
    bool isCurrentlySpeaking = speakingMessages[message] ?? false;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 10,
        ),
        if (!isUser)
          CircleAvatar(
            backgroundColor: MainGreen,
            child: Image(
              image: AssetImage('assets/images/bot.png'),
              height: 50, // Reduced height of the image
              width: 45, // Reduced width of the image
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 4, bottom: 4, left: 5, right: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? MainGreen : Colors.grey,
              borderRadius: isUser
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))
                  : BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: SmallTextWhite),
                const SizedBox(height: 4),
                Container(
                    width: 112,
                    child: Row(
                      children: [
                        Text(time, style: SmallTextWhite),
                        if (!isUser)
                          Align(
                            alignment:
                                Alignment.bottomRight, // Move icon to right
                            child: IconButton(
                              onPressed: onPlayAudio != null
                                  ? () => onPlayAudio!(message)
                                  : null, // Call function only if it's provided
                              icon: Icon(
                                isCurrentlySpeaking
                                    ? Icons.stop
                                    : Icons
                                        .volume_up, // Toggle icon for each message
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated Slide Transition for Messages
class SlideTransitionMessage extends StatelessWidget {
  final Widget child;

  const SlideTransitionMessage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
      curve: Curves.easeOut,
      builder: (context, Offset offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: child,
    );
  }
}

/// Animated Typing Indicator with Smooth Bounce Effect
/// Animated Typing Indicator with Smooth Bounce & Fade Effect
/// Best Typing Indicator with Smooth Bouncing Wave Effect
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _bounceAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true);

    _bounceAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });

    _fadeAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        CircleAvatar(
          backgroundColor: MainGreen,
          child: Image(
            image: AssetImage('assets/images/bot.png'),
            height: 50, // Reduced height of the image
            width: 45, // Reduced width of the image
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimations[index].value,
                    child: Opacity(
                      opacity: _fadeAnimations[index].value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
