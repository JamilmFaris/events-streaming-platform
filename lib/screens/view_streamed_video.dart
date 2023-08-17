import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../design/tw_colors.dart';
import '../models/event.dart';
import '../request/request.dart';

class ViewStreamedVideoScreen extends StatefulWidget {
  static const String routeName = '/view-streamed-video';
  final int talkId = 24;
  ViewStreamedVideoScreen({super.key});

  @override
  State<ViewStreamedVideoScreen> createState() =>
      _ViewStreamedVideoScreenState();
}

class _ViewStreamedVideoScreenState extends State<ViewStreamedVideoScreen> {
  bool isFullscreen = false;

  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('http://192.168.1.9:8080/live/${widget.talkId}.m3u8'),
      httpHeaders: {
        'Authorization':
            'Bearer a915a768bc3debab8b7ff356d64441f3686d91ae5bbdcf220843ee348e877cdd',
      },
    );
    _videoPlayerController.initialize().then((value) {
      setState(() {});
    });
    print('headers ${_videoPlayerController.httpHeaders}');

    super.initState();
  }

  void toggleFullscreen() {
    setState(() {
      if (isFullscreen) {
        exitFullScreen();
      } else {
        enterFullScreen();
      }
    });
  }

  void enterFullScreen() {
    setState(() async {
      print('enter fullscreen');
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
      isFullscreen = true;
    });
  }

  void exitFullScreen() {
    setState(() async {
      print('exit fullscreen');
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      isFullscreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final additionalSize = MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom +
        48;
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _videoPlayerController.value.isInitialized
                ? Container(
                    width: double.infinity,
                    height: constraints.maxHeight - additionalSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
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
                : const Text('waiting...'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _videoPlayerController.seekTo(const Duration(seconds: -10));
                  },
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _videoPlayerController.value.isPlaying
                        ? _videoPlayerController.pause()
                        : _videoPlayerController.play();
                    setState(() {});
                  },
                  icon: Icon(
                    _videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _videoPlayerController.seekTo(const Duration(seconds: 10));
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
    _videoPlayerController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
