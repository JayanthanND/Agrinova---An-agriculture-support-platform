import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FlutterChatScreen extends StatefulWidget {
  final String senderId;
  final String senderCollection;
  final String receiverId;
  final String receiverCollection;
  final String receiverName;
  final String receiverProfile;

  const FlutterChatScreen({
    super.key,
    required this.senderId,
    required this.senderCollection,
    required this.receiverId,
    required this.receiverCollection,
    required this.receiverName,
    required this.receiverProfile,
  });

  @override
  _FlutterChatScreenState createState() => _FlutterChatScreenState();
}

class _FlutterChatScreenState extends State<FlutterChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<types.Message> _messages = [];
  late types.User _currentUser;
  late types.User _receiverUser;

  @override
  void initState() {
    super.initState();
    _currentUser = types.User(id: widget.senderId);
    _receiverUser =
        types.User(id: widget.receiverId, firstName: widget.receiverName);
    _loadMessages();
  }

  /// 🔥 Load messages from Firestore into `flutter_chat_ui`
  Future<void> _loadMessages() async {
    String chatPath =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats';

    _firestore
        .collection(chatPath)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<types.Message> loadedMessages = snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
          return types.ImageMessage(
            size: 10,
            id: doc.id,
            author: data['senderId'] == widget.senderId
                ? _currentUser
                : _receiverUser,
            createdAt: timestamp.millisecondsSinceEpoch,
            name: "Image",
            uri: data['imageUrl'],
          );
        } else {
          return types.TextMessage(
            id: doc.id,
            author: data['senderId'] == widget.senderId
                ? _currentUser
                : _receiverUser,
            createdAt: timestamp.millisecondsSinceEpoch,
            text: data['message'],
          );
        }
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
      });
    });
  }

  /// 🔥 Send a text message
  void _sendMessage(types.PartialText message) async {
    String messageId = const Uuid().v4();
    String chatPathSender =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats/$messageId';
    String chatPathReceiver =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats/$messageId';

    Map<String, dynamic> messageData = {
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': message.text,
      'imageUrl': '',
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'isRead': false,
    };

    await _firestore.doc(chatPathSender).set(messageData);
    await _firestore.doc(chatPathReceiver).set(messageData);
  }

  /// 🔥 Send an image message
  Future<void> _sendImage(String imageUrl) async {
    String messageId = const Uuid().v4();
    String chatPathSender =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats/$messageId';
    String chatPathReceiver =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats/$messageId';

    Map<String, dynamic> messageData = {
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': '',
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'isRead': false,
    };

    await _firestore.doc(chatPathSender).set(messageData);
    await _firestore.doc(chatPathReceiver).set(messageData);
  }

  /// 🔥 Delete a message
  Future<void> _deleteMessage(String messageId) async {
    String senderPath =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats/$messageId';
    String receiverPath =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats/$messageId';

    await _firestore.doc(senderPath).delete();
    await _firestore.doc(receiverPath).delete();
  }

  /// 🔥 Handle sending text message via UI
  void _handleSendPressed(types.PartialText message) {
    _sendMessage(message);
  }

  /// 🔥 Handle media selection (images, videos, files)
  Future<void> _handleMediaSelection() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? media = await _picker.pickImage(source: ImageSource.gallery);

    if (media == null) return;

    File file = File(media.path);
    String fileName = const Uuid().v4();
    Reference storageRef =
        FirebaseStorage.instance.ref().child('chats/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    _sendImage(downloadURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        onAttachmentPressed: _handleMediaSelection,
        user: _currentUser,
        showUserAvatars: true,
        showUserNames: true,
        theme: const DefaultChatTheme(
          inputTextColor: Colors.black,
          backgroundColor: Colors.white,
          primaryColor: Colors.blue,
        ),
      ),
    );
  }
}
