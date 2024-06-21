import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/data/chat/chat_room.dart';
import 'package:fitapp/data/chat/message.dart';
import 'package:fitapp/pages/view/video_call/join_call.dart';
import 'package:fitapp/pages/view/video_call/video_call_screen.dart';
import 'package:fitapp/pages/widgets/chat_bubble.dart';
import 'package:fitapp/pages/widgets/image_bubble.dart';
import 'package:fitapp/services/database/firebase_cloud.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  const ChatRoomScreen(
      {super.key, required this.roomId, required this.userName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageCtrl = TextEditingController();
  ValueNotifier<bool> videoCallNotifier = ValueNotifier(false);
  User currentUser = FirebaseAuth.instance.currentUser!;
  File? _imgFile;
  String? _imgUrl;

  final scrollCtrl = ScrollController();

  void _videoCallOn() async {
    await Future.delayed(const Duration(microseconds: 1));
    videoCallNotifier.value = true;
  }

  void _videoCallOff() async {
    await Future.delayed(const Duration(microseconds: 1));
    videoCallNotifier.value = false;
  }

  Future<void> onSendMessage(
      String roomId, String currentUserId, String msgType) async {
    FirestoreDatabase()
        .sendMessage(roomId, currentUserId, messageCtrl.text, msgType);
    scrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    messageCtrl.clear();
  }

  // Future _pickImageFromGallery() async {
  //   final imgPicker =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);

  //   if (imgPicker == null) return;
  //   setState(() {
  //     _selectedImg = File(imgPicker.path);
  //   });
  // }

  // Future _useCamera() async {
  //   final imgPicker = await ImagePicker().pickImage(source: ImageSource.camera);
  //   if (imgPicker == null) return;
  //   setState(() {
  //     _selectedImg = File(imgPicker.path);
  //   });
  // }

  Future _pickImage(ImageSource source) async {
    final imgPicker = await ImagePicker().pickImage(source: source);
    if (imgPicker == null) return;

    setState(() {
      _imgFile = File(imgPicker.path);
      if (_imgFile != null) {
        FirebaseCloud().uploadImage(_imgFile!, widget.roomId);
      }
    });
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    scrollCtrl.dispose();
    videoCallNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String roomId = widget.roomId;
    String userName = widget.userName;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Text(
          userName,
          style: TextStyle(color: Colors.cyan[200]),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(color: Colors.cyan[200]),
        actions: [
          ValueListenableBuilder(
            valueListenable: videoCallNotifier,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: videoCallNotifier.value
                    ? JoinCall(roomId: roomId)
                    : IconButton(
                        onPressed: () {
                          FirestoreDatabase().setVideoCallState(roomId, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoCallScreen(
                                      roomId: roomId,
                                    )),
                          );
                        },
                        icon: const Icon(Icons.video_chat, size: 34),
                      ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildMessageList(roomId, currentUser),
          // _imgUrl != null
          //     ? ImageBubble(
          //         imageUrl: _imgUrl!,
          //         senderId: '8uxGqaWRwHZleVgR3qBqwyQB0pt1',
          //         currentUserId: currentUser.uid)
          //     : const Text('Please select an image.'),
          _buildUserInput(roomId, currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageList(String roomId, User currentUser) {
    return StreamBuilder<ChatRoom>(
      stream: FirestoreDatabase().getChatHistory(roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          ChatRoom data = snapshot.data!;

          if (data.isOpen) {
            print('call _videoCallOn');
            _videoCallOn();
          } else if (!data.isOpen) {
            print('calling _videoCallOff');
            _videoCallOff();
          }
          List<Message> messages = data.messages;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  controller: scrollCtrl,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, idx) {
                    var msg = messages[idx];
                    if (msg.msgType == 'image') {
                      return ImageBubble(
                          imageUrl: msg.content,
                          senderId: msg.senderId,
                          currentUserId: currentUser.uid);
                    } else {
                      return ChatBubble(
                        message: messages[idx],
                        currentUserId: currentUser.uid,
                      );
                    }
                  },
                ),
              ),
            ),
          );
        } else {
          return const Text('No data.');
        }
      },
    );
  }

  Widget _buildUserInput(String roomId, User currentUser) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_outlined),
            iconSize: 35,
            color: Colors.cyan[200],
          ),
          IconButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            iconSize: 35,
            color: Colors.cyan[200],
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              alignment: Alignment.center,
              width: 200,
              height: 100,
              child: SingleChildScrollView(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: messageCtrl,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: Colors.black54),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.grey[200]),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => onSendMessage(roomId, currentUser.uid, "text"),
            icon: const Icon(Icons.send_rounded),
            iconSize: 35,
            color: Colors.cyan[200],
          ),
        ],
      ),
    );
  }
}
