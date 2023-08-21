import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../design/tw_colors.dart';
import '../request/request.dart';

class ViewStreamedVideoScreen extends StatefulWidget {
  static const String routeName = '/view-streamed-video';
  final int talkId;
  ViewStreamedVideoScreen({required this.talkId, super.key});

  @override
  State<ViewStreamedVideoScreen> createState() =>
      _ViewStreamedVideoScreenState();
}

class _ViewStreamedVideoScreenState extends State<ViewStreamedVideoScreen> {
  bool isFullScreen = false;

  VideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Request.getTalkKey(context).then((key) {
      if (key != null) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(
            'http://${Request.authority}/live/${widget.talkId}.m3u8?token=$key',
          ),
        );
      }
    }).then((value) {
      _videoPlayerController!.initialize().then((value) {
        setState(() {});
      });
    });

    super.initState();
  }

  void toggleFullscreen() {
    setState(() {
      if (isFullScreen) {
        exitFullScreen();
      } else {
        enterFullScreen();
      }
    });
  }

  Future<void> enterFullScreen() async {
    print('enter fullscreen');
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    setState(() {
      isFullScreen = true;
    });
  }

  void exitFullScreen() {
    setState(() async {
      print('exit fullscreen');
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      isFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final additionalSize = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom +
        48;
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: isFullScreen
          ? null
          : AppBar(
              title: const Text(
                'Your video',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return _videoPlayerController == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _videoPlayerController!.value.isInitialized
                      ? SizedBox(
                          width: double.infinity,
                          height: constraints.maxHeight - additionalSize,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                  onPressed: toggleFullscreen,
                                ),
                              )
                            ],
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _videoPlayerController!
                              .seekTo(const Duration(seconds: -10));
                        },
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _videoPlayerController!.value.isPlaying
                              ? _videoPlayerController!.pause()
                              : _videoPlayerController!.play();
                          setState(() {});
                        },
                        icon: Icon(
                          _videoPlayerController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _videoPlayerController!
                              .seekTo(const Duration(seconds: 10));
                        },
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
      }),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
