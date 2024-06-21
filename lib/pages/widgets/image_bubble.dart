import 'package:fitapp/pages/widgets/image_screen.dart';
import 'package:fitapp/services/database/firebase_cloud.dart';
import 'package:flutter/material.dart';

class ImageBubble extends StatefulWidget {
  final String imageUrl;
  final String senderId;
  final String currentUserId;
  const ImageBubble(
      {super.key,
      required this.imageUrl,
      required this.senderId,
      required this.currentUserId});

  @override
  State<ImageBubble> createState() => _ImageBubbleState();
}

class _ImageBubbleState extends State<ImageBubble> {
  void _imageTap(String imageUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageScreen(imageUrl: imageUrl),
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool iamSender = widget.senderId == widget.currentUserId;
    var msgAlignment = iamSender ? Alignment.centerRight : Alignment.centerLeft;
    return FutureBuilder<String>(
      future: FirebaseCloud().downloadImage(widget.imageUrl),
      builder: (context, snapshot) {
        var file = snapshot.data;
        return Align(
          alignment: msgAlignment,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => _imageTap(file!),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      iamSender ? Colors.cyan.shade200 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: file != null
                      ? Container(
                          height: 200,
                          width: 140,
                          decoration: BoxDecoration(
                              color: iamSender
                                  ? Colors.cyan.shade200
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: NetworkImage(file),
                                  fit: BoxFit.cover)),
                        )
                      : const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
