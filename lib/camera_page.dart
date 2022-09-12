import 'dart:io';
import 'package:flutter/material.dart';

import 'custom_camera.dart';
import 'video_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return CustomCamera(
      color: Colors.white70,
      onImageCaptured: (value) {
        final path = value.path;
        if (path.contains('.jpg')) {
          showDialog(
              context: context,
              builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Photo'),
                  ),
                  body: AlertDialog(
                    content: Image.file(File(path)),
                  ),
                );
              });
        }
      },
      onVideoRecorded: (value) {
        File file = File(value.path);
        final path = value.path;
        if (path.contains('.mp4')) {
          final route = MaterialPageRoute(
            fullscreenDialog: false,
            builder: (_) => VideoPage(filePath: path, file: file),
          );
          Navigator.push(context, route);
        }
        ///Show video preview .mp4
      },
    );
    // return Container();
  }
}

