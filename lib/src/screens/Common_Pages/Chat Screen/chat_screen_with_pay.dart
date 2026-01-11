import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Chat%20Screen/payment_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../../Customs/constants.dart';

class ChatScreenWithPay extends StatefulWidget {
  final String senderId;
  final String senderCollection;

  final String receiverId;
  final String receiverCollection;
  final String receiverName;
  final String receiverProfile;

  const ChatScreenWithPay({
    super.key,
    required this.senderId,
    required this.senderCollection,
    required this.receiverId,
    required this.receiverCollection,
    required this.receiverName,
    required this.receiverProfile,
  });

  @override
  _ChatScreenWithPayState createState() => _ChatScreenWithPayState();
}

class _ChatScreenWithPayState extends State<ChatScreenWithPay>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isChatScreenActive = false;
  String? _replyMessage;
  bool _isReplyingToMe = false;
  bool _isReplying = false;
  bool _isReceiverOnline = false;
  String? _receiverPhoneNumber;
  bool _isTyping = false;
  // final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioFilePath;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  void _setReplyMessage(String message, bool isMe) {
    setState(() {
      _replyMessage = message;
      _isReplying = true;
    });
  }

  User? user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add the observer
    user = _auth.currentUser;
    _setUserOnline();
    _initializeChat();
    _fetchReceiverPhoneNumber();
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // App is in the background
      _isChatScreenActive = false;
      _setUserOffline();
    } else if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _isChatScreenActive = true;
      _setUserOnline();
      _markMessagesAsSeen();
      _markMessagesAsRead();
    }
  }

  void _onMessageChanged(String text) {
    setState(() {
      _isTyping = text.trim().isNotEmpty;
    });
  }

  Future<void> _initializeChat() async {
    if (user == null) return;

    String chatPathSender =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}';
    String chatPathReceiver =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}';

    try {
      // Check if chat exists for sender
      DocumentSnapshot senderChatDoc =
          await _firestore.doc(chatPathSender).get();
      if (!senderChatDoc.exists) {
        await _firestore.doc(chatPathSender).set({'initialized': true});
      }

      // Check if chat exists for receiver
      DocumentSnapshot receiverChatDoc =
          await _firestore.doc(chatPathReceiver).get();
      if (!receiverChatDoc.exists) {
        await _firestore.doc(chatPathReceiver).set({'initialized': true});
      }

      print("Chat collections initialized!");
    } catch (e) {
      print("Error initializing chat: $e");
    }
  }

  void _setUserOnline() {
    if (mounted && user != null) {
      _firestore
          .collection(widget.senderCollection)
          .doc(widget.senderId)
          .update({'status': 'online'});
    }
  }

  void _setUserOffline() {
    if (user != null) {
      _firestore
          .collection(widget.senderCollection)
          .doc(widget.senderId)
          .update({'status': 'offline'});
    }
  }

  Future<void> _fetchReceiverPhoneNumber() async {
    try {
      DocumentSnapshot receiverDoc = await _firestore
          .collection(widget.receiverCollection)
          .doc(widget.receiverId)
          .get();

      if (receiverDoc.exists) {
        setState(() {
          _receiverPhoneNumber =
              receiverDoc['phoneNumber'] ?? ''; // Assuming 'phone' is the field
        });
        print("Receiver Phone Number: $_receiverPhoneNumber");
      }
    } catch (e) {
      print("Error fetching receiver phone number: $e");
    }
  }

  void _makePhoneCall(BuildContext context) async {
    if (_receiverPhoneNumber == null || _receiverPhoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receiver phone number not available')),
      );
      return;
    }

    final String sanitizedNumber = _receiverPhoneNumber!.startsWith('+')
        ? _receiverPhoneNumber!
        : '+91$_receiverPhoneNumber!'; // Replace '+91' with your country code

    final Uri url = Uri(scheme: 'tel', path: sanitizedNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  void _showSetUPIIDDialog(BuildContext context) {
    TextEditingController upiIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set UPI ID"),
        content: TextField(
          controller: upiIdController,
          decoration: InputDecoration(hintText: "Enter your UPI ID"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (upiIdController.text.trim().isNotEmpty) {
                await _firestore
                    .collection(widget.senderCollection)
                    .doc(widget.senderId)
                    .update({'upiId': upiIdController.text.trim()});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("UPI ID set successfully!")),
                );
                Navigator.pop(context);
                _searchReceiverUPIID(
                    context); // Proceed to search for receiver's UPI ID
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _searchReceiverUPIID(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: _fetchReceiverUPIID(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Receiver's UPI ID not found!"));
            } else {
              String receiverUpiId = snapshot.data!;
              Navigator.pop(context); // Close the bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    senderId: widget.senderId,
                    senderCollection: widget.senderCollection,
                    recieverId: widget.senderId,
                    recieverCollection: widget.senderCollection,
                    receiverName: widget.receiverName,
                    receiverProfile: widget.receiverProfile,
                    receiverUpiId: receiverUpiId,
                  ),
                ),
              );
              return Container(); // Placeholder
            }
          },
        );
      },
    );
  }

  Future<String?> _fetchReceiverUPIID() async {
    try {
      DocumentSnapshot receiverDoc = await _firestore
          .collection(widget.receiverCollection)
          .doc(widget.receiverId)
          .get();
      return receiverDoc['upiId'] ?? '';
    } catch (e) {
      print("Error fetching receiver UPI ID: $e");
      return null;
    }
  }

  Future<void> _sendMessage(String message,
      {String? imageUrl,
      String? documentUrl,
      String? documentName,
      int? documentSize,
      String? repliedMessage,
      String? repliedMessageSender}) async {
    if (message.trim().isEmpty && imageUrl == null && documentUrl == null) {
      print(
          "No message, image, or document to send."); // Debug: No content to send
      return;
    }

    String messageId = const Uuid().v4();

    String senderPath =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats/$messageId';
    String receiverPath =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats/$messageId';
    print("url$documentUrl");
    print(imageUrl);

    Map<String, dynamic> messageData = {
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': message,
      'imageUrl': imageUrl ?? '',
      'documentUrl': documentUrl ?? '',
      'documentName': documentName ?? '', // Store the document name
      'documentSize': documentSize ?? 0,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'isRead': false,
      'repliedMessage': repliedMessage ?? '',
      'repliedMessageSender': repliedMessageSender ?? '',
    };

    try {
      await _firestore.doc(senderPath).set(messageData);
      await _firestore.doc(receiverPath).set(messageData);
      print("succceeesssssss");

      void _setReplyMessage(String message, bool isMe) {
        setState(() {
          _replyMessage = message;
          _isReplyingToMe = isMe;
        });
      }

      print("Message sent with ID: $messageId");
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> _markMessagesAsSeen() async {
    if (mounted) {
      String chatPath =
          '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats';

      _firestore
          .collection(chatPath)
          .where('seen', isEqualTo: false)
          .snapshots()
          .listen((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'seen': true});
        }
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (mounted) {
      String chatPath =
          '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats';

      _firestore
          .collection(chatPath)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'isRead': true});
        }
      });
    }
  }

  Future<void> _deleteMessage(String messageId, bool forEveryone) async {
    if (messageId.isEmpty) {
      print("Error: messageId is empty or null.");
      return;
    }
    print("Deleting message with ID: ${messageId}");

    String senderPath =
        '${widget.senderCollection}/${widget.senderId}/messages/${widget.receiverId}/chats/$messageId';
    String receiverPath =
        '${widget.receiverCollection}/${widget.receiverId}/messages/${widget.senderId}/chats/$messageId';

    if (forEveryone) {
      await _firestore.doc(senderPath).delete();
      await _firestore.doc(receiverPath).delete();
    } else {
      await _firestore.doc(senderPath).delete();
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickMediaFromGallery(); // Open the gallery to pick an image
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text('Document'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickDocument(); // Open the file picker to select a document
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _uploadFile(File(image.path), "none");
    }
  }

  Future<void> _pickMediaFromGallery() async {
    // Request storage permission
    await Permission.storage.request();

    try {
      // Pick an image from the gallery using image_picker
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, // Pick from gallery
        maxHeight: 1080, // Optional, set max height
        maxWidth: 1080, // Optional, set max width
      );

      if (image != null) {
        File file = File(image.path); // Convert XFile to File
        _uploadFile(file, "none"); // Call your upload function
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, bool isMe,
      String receiverName, DateTime timestamp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor:
              Colors.black, // Background color for full-screen mode
          extendBodyBehindAppBar:
              true, // Allow content to extend behind the AppBar
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Transparent AppBar
            elevation: 0, // Remove shadow
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe
                      ? "You"
                      : receiverName, // Display "You" if sender is current user
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_getFormattedDate(timestamp)} at ${_formatTime(timestamp)}", // Display date and time
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          body: InteractiveViewer(
            panEnabled: true, // Allow panning
            minScale: 0.5, // Minimum zoom level
            maxScale: 4, // Maximum zoom level
            boundaryMargin: EdgeInsets.all(
                double.infinity), // Allow panning beyond image boundaries
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Ensure the image fits within the screen
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    // Use the file_picker package to select a document
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt'
      ], // Add allowed file types
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String documentName =
          result.files.single.name; // Capture the document name
      _uploadFile(file, documentName); // Upload the file to Firebase Storage
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      print("Storage permission already granted");
      return true;
    }

    // Request permission
    var status = await Permission.storage.request();
    print("Permission status: $status");

    // Check if permission was granted
    if (status.isGranted) {
      print("Storage permission granted");
      return true;
    } else {
      print("Storage permission denied");
      return false;
    }
  }

  Future<void> _downloadDocument(
    String url,
    String fileName, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Request storage permission (for Android 10 and below)

      // Get the external downloads directory
      Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');

      if (!await downloadsDirectory.exists()) {
        throw Exception("Downloads directory not found");
      }

      // Define the file path
      String filePath = '${downloadsDirectory.path}/$fileName';

      // Create a Dio instance
      Dio dio = Dio();

      // Start the download
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (onProgress != null) {
            onProgress(received, total); // Update progress
          }
        },
      );

      print("File downloaded and saved to: $filePath");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File downloaded to Downloads folder!")),
      );
    } catch (e) {
      print("Error downloading file: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download file: $e")),
      );
    }
  }

  Future<void> _uploadFile(File file, String documentName) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String fileExtension =
          file.path.split('.').last; // Get the file extension
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('chats/$fileName.$fileExtension');

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      int fileSize = await file.length();

      if (fileExtension.toLowerCase() == 'jpg' ||
          fileExtension.toLowerCase() == 'jpeg' ||
          fileExtension.toLowerCase() == 'png' ||
          fileExtension.toLowerCase() == 'gif') {
        // If the file is an image, send it as an image message
        _sendMessage('', imageUrl: downloadURL);
      } else {
        // If the file is not an image, send it as a document message
        _sendMessage(
          '', documentUrl: downloadURL, documentName: documentName,
          documentSize: fileSize, // Pass the file size
        );
        print("Name: $downloadURL");
      }
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  String _getFormattedDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return "Today";
    } else if (dateTime.isAfter(yesterday)) {
      return "Yesterday";
    } else {
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    }
  }

  String _getMonthName(int month) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    String formattedMinute = minute < 10 ? "0$minute" : "$minute";
    return "$hour:$formattedMinute $period";
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(60), // Increased height for better spacing
          child: Container(
            color: Colors.grey.shade300, // Background color like an app bar
            padding: EdgeInsets.only(top: 50, bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                // 🔹 Back Arrow
                Expanded(
                  flex: 0,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                // 🔹 Profile Picture & Name (Centered)
                Expanded(
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Centered Name
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.receiverProfile),
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.receiverName,
                        style: NormalTextBlack,
                        overflow: TextOverflow.ellipsis, // Prevents overflow
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: IconButton(
                        onPressed: () {
                          _makePhoneCall(context);
                        },
                        icon: Icon(Icons.phone)))
              ],
            ),
          ),
        ),
        body:
            // 🔹 Background Image
            Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "assets/images/chat_bg.jpg"), // Ensure this image exists
                fit: BoxFit.cover,
                opacity: .5),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection(widget.senderCollection)
                      .doc(widget.senderId)
                      .collection('messages')
                      .doc(widget.receiverId)
                      .collection('chats')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No messages yet!"));
                    }

                    List<DocumentSnapshot> messages = snapshot.data!.docs;
                    String? lastDisplayedDate;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var doc = messages[index];
                        bool isMe = doc['senderId'] == widget.senderId;
                        // Handle null timestamp
                        DateTime messageTime;
                        if (doc['timestamp'] != null) {
                          messageTime =
                              (doc['timestamp'] as Timestamp).toDate();
                        } else {
                          messageTime =
                              DateTime.now(); // Fallback to current time
                        }

                        String formattedDate = _getFormattedDate(messageTime);
                        String formattedTime = _formatTime(messageTime);

                        bool showDateHeader = index == messages.length - 1 ||
                            _getFormattedDate((messages[index + 1]['timestamp']
                                        as Timestamp)
                                    .toDate()) !=
                                formattedDate;

                        bool isRead = doc['isRead'] ?? false;
                        bool isSeen = doc['seen'] ?? false;

                        IconData tickIcon = isRead
                            ? Icons.done_all
                            : (isSeen ? Icons.done_all : Icons.done);
                        Color tickColor =
                            isRead ? Color(0xFF34B7F1) : Colors.grey;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateHeader)
                              Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: isMe
                                  ? GestureDetector(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Delete Message?",
                                              style: TextBlack,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  _deleteMessage(doc.id, false);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete for Me"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteMessage(doc.id, true);
                                                  Navigator.pop(context);
                                                },
                                                child:
                                                    Text("Delete for Everyone"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      onHorizontalDragUpdate: (details) {
                                        if (details.primaryDelta! > 15) {
                                          _setReplyMessage(
                                              doc['message'],
                                              doc['senderId'] ==
                                                  widget.senderId);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Color(0xFF075E54)
                                              : Color(0xFF808080),
                                          borderRadius: isMe
                                              ? BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10))
                                              : BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                        ),
                                        child: Stack(
                                          children: [
                                            if (doc['imageUrl'] != null &&
                                                doc['imageUrl'].isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  // Open full-screen image preview
                                                  _showFullScreenImage(
                                                    context,
                                                    doc['imageUrl'],
                                                    doc['senderId'] ==
                                                        widget.senderId, // isMe
                                                    widget
                                                        .receiverName, // Receiver's name
                                                    (doc['timestamp']
                                                            as Timestamp)
                                                        .toDate(), // Timestamp
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    doc['imageUrl'],
                                                    width:
                                                        200, // Adjust the width as needed
                                                    height:
                                                        200, // Adjust the height as needed
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            if (doc['documentUrl'] != null &&
                                                doc['documentUrl'].isNotEmpty)
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    _isDownloading =
                                                        true; // Start download
                                                    _downloadProgress =
                                                        0.0; // Reset progress
                                                  });

                                                  // Download the document
                                                  await _downloadDocument(
                                                    doc['documentUrl'],
                                                    doc['documentName'],
                                                    onProgress:
                                                        (received, total) {
                                                      setState(() {
                                                        _downloadProgress =
                                                            received /
                                                                total; // Update progress
                                                      });
                                                    },
                                                  );

                                                  setState(() {
                                                    _isDownloading =
                                                        false; // End download
                                                  });
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width:
                                                              50, // Fixed size for the document preview
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.1), // Background effect
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .insert_drive_file,
                                                              size: 40,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          doc['documentName'],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          _formatFileSize(doc[
                                                              'documentSize']),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (doc['isPayment'] == true)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 16),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "Payment Completed",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "₹${doc['paymentAmount']}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            // Display message text if message is present
                                            if (doc['message'] != null &&
                                                doc['message'].isNotEmpty)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 80),
                                                child: Text(
                                                  doc['message'],
                                                  style: TextStyle(
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    formattedTime,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white70),
                                                  ),
                                                  if (isMe) // ✅ Show ticks only for sender's messages
                                                    Row(
                                                      children: [
                                                        SizedBox(width: 4),
                                                        Icon(tickIcon,
                                                            size: 12,
                                                            color: tickColor),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Delete Message?",
                                              style: TextBlack,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  _deleteMessage(doc.id, false);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete for Me"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      onHorizontalDragUpdate: (details) {
                                        if (details.primaryDelta! > 15) {
                                          _setReplyMessage(
                                              doc['message'],
                                              doc['senderId'] ==
                                                  widget.senderId);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Color(0xFF075E54)
                                              : Color(0xFF808080),
                                          borderRadius: isMe
                                              ? BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10))
                                              : BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(10),
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10)),
                                        ),
                                        child: Stack(
                                          children: [
                                            if (doc['imageUrl'] != null &&
                                                doc['imageUrl'].isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  // Open full-screen image preview
                                                  _showFullScreenImage(
                                                    context,
                                                    doc['imageUrl'],
                                                    doc['senderId'] ==
                                                        widget.senderId, // isMe
                                                    widget
                                                        .receiverName, // Receiver's name
                                                    (doc['timestamp']
                                                            as Timestamp)
                                                        .toDate(), // Timestamp
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    doc['imageUrl'],
                                                    width:
                                                        200, // Adjust the width as needed
                                                    height:
                                                        200, // Adjust the height as needed
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            if (doc['documentUrl'] != null &&
                                                doc['documentUrl'].isNotEmpty)
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    _isDownloading =
                                                        true; // Start download
                                                    _downloadProgress =
                                                        0.0; // Reset progress
                                                  });

                                                  // Download the document
                                                  await _downloadDocument(
                                                    doc['documentUrl'],
                                                    doc['documentName'],
                                                    onProgress:
                                                        (received, total) {
                                                      setState(() {
                                                        _downloadProgress =
                                                            received /
                                                                total; // Update progress
                                                      });
                                                    },
                                                  );

                                                  setState(() {
                                                    _isDownloading =
                                                        false; // End download
                                                  });
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          width:
                                                              50, // Fixed size for the document preview
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.1), // Background effect
                                                          ),
                                                          child: Icon(
                                                              Icons
                                                                  .insert_drive_file,
                                                              size: 40,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          doc['documentName'],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          _formatFileSize(doc[
                                                              'documentSize']),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (doc['isPayment'] == true)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 16),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "Payment Completed",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "₹${doc['paymentAmount']}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            // Display message text if message is present
                                            if (doc['message'] != null &&
                                                doc['message'].isNotEmpty)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 80),
                                                child: Text(
                                                  doc['message'],
                                                  style: TextStyle(
                                                    color: isMe
                                                        ? Colors.white
                                                        : Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    formattedTime,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white70),
                                                  ),
                                                  if (isMe) // ✅ Show ticks only for sender's messages
                                                    Row(
                                                      children: [
                                                        SizedBox(width: 4),
                                                        Icon(tickIcon,
                                                            size: 12,
                                                            color: tickColor),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // 🔹 Message Input Section
              Column(
                children: [
                  if (_replyMessage != null)
                    Container(
                      color: Colors.grey[300],
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Replying to ${_isReplyingToMe ? "Yourself" : widget.receiverName}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_replyMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _replyMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Row(
                      children: [
                        // Camera Icon

                        // Chat Input Field
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                // Emoji Icon
                                // Icon(Icons.emoji_emotions_outlined,
                                //     color: Colors.grey[700]),
                                IconButton(
                                  icon: Icon(Icons.currency_rupee,
                                      color: Colors.grey[700]),
                                  onPressed: () async {
                                    // Check if sender's UPI ID is set
                                    DocumentSnapshot senderDoc =
                                        await _firestore
                                            .collection(widget.senderCollection)
                                            .doc(widget.senderId)
                                            .get();
                                    String senderUpiId =
                                        senderDoc['upiId'] ?? '';

                                    if (senderUpiId.isEmpty) {
                                      // Show dialog to set sender's UPI ID
                                      _showSetUPIIDDialog(context);
                                    } else {
                                      // Search for receiver's UPI ID
                                      _searchReceiverUPIID(context);
                                    }
                                  },
                                ),
                                SizedBox(width: 8),
                                // TextField
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    onChanged: _onMessageChanged,
                                    decoration: InputDecoration(
                                      hintText: "Type a message...",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                // Attach File Icon
                                IconButton(
                                  onPressed: () {
                                    _showAttachmentOptions(context);
                                  },
                                  icon: Icon(Icons.attach_file,
                                      color: Colors.grey[700]),
                                ),

                                SizedBox(width: 8),
                                // Camera Icon (Inside TextField)
                                IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      color: Colors.grey[700]),
                                  onPressed: _pickImageFromCamera,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Send / Mic Button
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF00A163),
                          child: IconButton(
                            icon: Icon(
                              _isTyping ? Icons.send : Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_isTyping) {
                                if (_messageController.text.trim().isNotEmpty) {
                                  _sendMessage(_messageController.text.trim());
                                  _messageController.clear();
                                  setState(() {
                                    _isTyping = false;
                                  });
                                }
                              } else {
                                // Handle microphone press action if needed
                              }
                            },
// Replace with mic function if needed
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    _setUserOffline(); // ✅ Keep your existing logic
    super.dispose();
  }
}
