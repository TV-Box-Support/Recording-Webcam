import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'api/uploadFile.dart';
import 'custom_camera.dart';
import 'video_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return CustomCamera(
      color: Colors.white70,
      onImageCaptured: (value) {
        final path = value.path;
        final file = File(path);
        if (path.contains('.jpg')) {
          showDialog(
              context: context,
              builder: (context) {
                return Scaffold(
                    appBar: AppBar(
                      title: const Text('Photo'),
                      centerTitle: true,
                      backgroundColor: Colors.black,
                      actions: [
                        IconButton(
                            onPressed: () async {
                              var request = await uploadFile(context, file)
                                  .whenComplete(() {});
                              if (request) {
                                Fluttertoast.showToast(
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
                    body: Transform.rotate(
                      angle: 90 * pi / 180,
                      child: AlertDialog(
                        content: Image.file(File(path)),
                      ),
                    ));
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
      },
    );
  }
}
