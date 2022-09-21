import 'dart:io';

import 'package:flutter/material.dart';

import 'captures_screen.dart';

class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  const PreviewScreen({
    super.key,
    required this.imageFile,
    required this.fileList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CapturesScreen(
                      imageFileList: fileList,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('Go to all captures'),
            ),
          ),
          Expanded(
            child: Image.file(imageFile),
          ),
        ],
      ),
    );
  }
}
