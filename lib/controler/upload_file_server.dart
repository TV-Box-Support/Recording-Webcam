import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class UpdateFile extends StatefulWidget {
  final File file;

  const UpdateFile({super.key, required this.file});

  @override
  _UpdateFileState createState() => _UpdateFileState();
}

class _UpdateFileState extends State<UpdateFile> {
  final TextEditingController _urlController = TextEditingController();
  String _url = "http://192.168.88.156:5000/uploadFile";
  late String error;

  Future<bool> uploadFile(BuildContext context, File file) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.black,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 15),
                Text(
                  'Uploading...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_url));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      error = e.toString();
    }
    return false;
  }

  Future<bool> _showDialog() async {
    bool click = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Url Upload',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            cursorColor: Colors.white,
            controller: _urlController,
            decoration: InputDecoration(
              hintText: _url,
              hintStyle: const TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.focused)) {
                    return Colors.green;
                  }
                  return Colors.white;
                }),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (_urlController.text.trim() != '') {
                  setState(() {
                    _url = _urlController.text.trim();
                  });
                }
                click = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return click;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      focusColor: Colors.grey,
      icon: const Icon(
        Icons.cloud_upload,
        color: Colors.white,
        size: 35,
      ),
      onPressed: () {
        _showDialog().then((done) {
          if (done) {
            uploadFile(context, widget.file).then((success) {
              Navigator.of(context).pop();
              if (success) {
                Fluttertoast.showToast(
                  msg: "Upload success",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Upload failed",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
            });
          }
        });
      },
    );
  }
}
