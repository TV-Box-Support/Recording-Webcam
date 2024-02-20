import 'dart:io';

import 'package:camera_app/controler/upload_file_server.dart';
import 'package:camera_app/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatefulWidget {
  final File file;

  const ImagePage({required this.file});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  //rotate BuilderFuture
  int quarterTurns = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
      quarterTurns = 1;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
      },
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            toolbarHeight: 60,
            leading: SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                focusColor: Colors.grey,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                },
              ),
            ),
            title: const Text(
              "Photo",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            actions: [
              SizedBox(
                width: 50,
                height: 50,
                child: UpdateFile(file: widget.file),
              ),
            ],
          ),
          body: RotatedBox(
            quarterTurns: quarterTurns,
            child: PhotoView(
              imageProvider: FileImage(widget.file),
              loadingBuilder: (context, progress) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          )),
    );
  }
}
