import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/services/agora_service.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;
  const VideoCallScreen({super.key, required this.roomId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  var currentUserId = FirebaseAuth.instance.currentUser!.uid;

  int localUid = 0;
  int? remoteUid;
  String appId = dotenv.env['APP_ID']!;
  late String channelName;
  late String token;

  bool isJoined = false; // Indicates if the local user has joined the channel
  bool isBroadcaster = true; // Client role
  RtcEngine? agoraEngine;
  late ClientRoleType role;
  ChannelMediaOptions options = const ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication1v1);

  @override
  void initState() {
    channelName = widget.roomId;
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine!.initialize(RtcEngineContext(appId: appId));
    role = isBroadcaster
        ? ClientRoleType.clientRoleBroadcaster
        : ClientRoleType.clientRoleAudience;
    await agoraEngine!.setClientRole(role: role);
    await agoraEngine!.enableVideo();
    await agoraEngine!.startPreview();
    // Register the event handler
    agoraEngine!.registerEventHandler(getEventHandler());
    // agoraEngine!
    //     .registerLocalUserAccount(appId: appId, userAccount: currentUserId);
    token = await AgoraService()
        .fetchToken(currentUserId, channelName, isBroadcaster);
    await agoraEngine!.joinChannelWithUserAccount(
        channelId: channelName,
        token: token,
        userAccount: currentUserId,
        options: options);
  }

  RtcEngineEventHandler getEventHandler() {
    return RtcEngineEventHandler(
      // Listen for the event that the token is about to expire

      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('Token expiring...');
        AgoraService().renewToken(agoraEngine, token);
      },
      // Occurs when a local user joins a channel
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("Local user uid:${connection.localUid} joined the channel");
        setState(() {
          isJoined = true;
        });
      },
      // Occurs when a remote user joins the channel
      onUserJoined: (RtcConnection connection, int uid, int elapsed) {
        debugPrint("Remote user uid:$uid joined the channel");
        setState(() {
          // remoteUids.add(uid);
          remoteUid = uid;
        });
      },
      // Occurs when a remote user leaves the channel
      onUserOffline:
          (RtcConnection connection, int uid, UserOfflineReasonType reason) {
        debugPrint("Remote user uid:$uid left the channel");
        setState(() {
          remoteUid = null;
        });
      },
    );
  }

  Future<void> leave() async {
    // Clear saved remote Uids
    remoteUid = null;
    // Leave the channel
    if (agoraEngine != null) {
      await agoraEngine!.leaveChannel();
    }
    isJoined = false;
    // Destroy the Agora engine instance
    // destroyAgoraEngine();
  }

  void destroyAgoraEngine() async {
    // Release the RtcEngine instance to free up resources
    if (agoraEngine != null) {
      await agoraEngine!.release();
      agoraEngine = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    // await leave();
    destroyAgoraEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: _remoteVideoView(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 150,
              height: 180,
              child: Center(
                child: _localVideoView(),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {},
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.grey[50],
            // fillColor: muted ? Colors.blueAccent : Colors.white,
            // padding: const EdgeInsets.all(12.0),
            child: const Icon(
              // muted ? Icons.mic_off_outlined : Icons.mic_none_outlined
              Icons.mic_none_outlined,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              leave();
              FirestoreDatabase().setVideoCallState(channelName, false);
              Navigator.pop(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(Icons.call_end, color: Colors.white, size: 35.0),
          ),
          // button to switch camera ??
        ],
      ),
    );
  }

  Widget _remoteVideoView() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine!,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _localVideoView() {
    if (isJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine!,
          canvas: const VideoCanvas(uid: 0),
          // Use uid = 0 for local view
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
