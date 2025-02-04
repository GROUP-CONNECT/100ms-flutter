//Package imports
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter_example/common/util/app_color.dart';
import 'package:hmssdk_flutter_example/hls-streaming/util/hls_title_text.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

//Project imports
import 'package:hmssdk_flutter_example/data_store/meeting_store.dart';

class HLSPlayer extends StatefulWidget {
  final String streamUrl;

  HLSPlayer({Key? key, required this.streamUrl}) : super(key: key);

  @override
  _HLSPlayerState createState() => _HLSPlayerState();
}

class _HLSPlayerState extends State<HLSPlayer> {
  @override
  void initState() {
    super.initState();
    context.read<MeetingStore>().hlsVideoController =
        VideoPlayerController.network(
      widget.streamUrl,
    )..initialize().then((_) {
            context.read<MeetingStore>().hlsVideoController!.play();
            setState(() {});
          });
  }

  @override
  void dispose() async {
    super.dispose();
    try {
      await context.read<MeetingStore>().hlsVideoController?.dispose();
      context.read<MeetingStore>().hlsVideoController = null;
    } catch (e) {
      //To handle the error when the user calls leave from hls-viewer role.
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeetingStore, VideoPlayerController?>(
        selector: (_, meetingStore) => meetingStore.hlsVideoController,
        builder: (_, controller, __) {
          return Scaffold(
              key: GlobalKey(),
              body: Center(
                child: controller?.value.isInitialized ?? false
                    ? AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller),
                      )
                    : HLSTitleText(
                        text: "Waiting for the HLS Streaming to start...",
                        textColor: themeDefaultColor,
                      ),
              ));
        });
  }
}
