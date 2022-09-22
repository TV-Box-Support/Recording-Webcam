import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';

import 'api/uploadFile.dart';
import 'custom_camera.dart';
import 'video_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with WidgetsBindingObserver{

  //rotate BuilderFuture
  int quarterTurns = 0;

  Future<void> CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          Fluttertoast.showToast(
              msg: "wifi đã kết nối",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.white54,
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
      }
    } on SocketException catch (_) {
      setState(() {
        Fluttertoast.showToast(
            msg: "Hãy kết nối wifi để có thể upload lên server",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.white54,
            textColor: Colors.white,
            fontSize: 16.0
        );
      });
    }
  }

  @override
  void initState() {
    CheckUserConnection();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ) {
      quarterTurns = 1;
    }
    return CustomCamera(
      color: Colors.white70,
      onImageCaptured: (value) {
        File file = File(value.path);
        final path = value.path;
        if (path.contains('.jpg')) {
          showDialog(
              context: context,
              builder: (context) {
                return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CameraPage()));
                        },
                      ),
                      // Builder(
                      //   builder: (BuildContext context) {
                      //     return IconButton(
                      //       icon: const Icon(Icons.menu),
                      //       onPressed: () { Scaffold.of(context).openDrawer(); },
                      //       tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                      //     );
                      //   },
                      // ),
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
                    body: RotatedBox(
                    quarterTurns: quarterTurns,
                      child: PhotoView(
                        imageProvider: FileImage(file),
                      ),
                    ));
              });
        }
      },
      onVideoRecorded: (value) {
        File file = File(value.path);
        final path = value.path;
        if (path.contains('.mp4')) {
          // final route = MaterialPageRoute(
          //   fullscreenDialog: false,
          //   builder: (_) => VideoPage(filePath: path, file: file),
          // );
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoPage(filePath: path, file: file)));
        }
      },
    );
  }
}
