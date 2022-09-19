import 'dart:async';
import 'dart:io';

import 'package:camera_app/api/uploadFile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final String filePath;
  final File file;

  const VideoPage({
    Key? key,
    required this.filePath,
    required this.file,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initVideoPlayer;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    _initVideoPlayer = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('preview'),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () async {
                var request =
                    await uploadFile(context, widget.file).whenComplete(() {});
                if (request) {
                  await Fluttertoast.showToast(
                      msg: "Upload Success!!!!!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.white54,
                      textColor: Colors.white,
                      fontSize: 20.0);
                }
              },
              icon: const Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 35,
              ))
        ],
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initVideoPlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_videoPlayerController),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_videoPlayerController.value.isPlaying) {
              _videoPlayerController.pause();
            } else {
              // If the video is paused, play it.
              _videoPlayerController.play();
            }
          });
        },
        backgroundColor: Colors.white,
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _videoPlayerController.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}
