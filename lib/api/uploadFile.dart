import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadFile(BuildContext context, File file) async {
  showDialog(
      //  The user CANNOT close this dialog  by pressing outside it
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return const Dialog(
          // The background color
          backgroundColor: Colors.black,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The loading indicator
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(
                  height: 15,
                ),
                // Some text
                Text(
                  'Uploading...',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        );
      });
  var request = http.MultipartRequest('POST', Uri.parse('http://192.168.88.156:5000/uploadFile'));
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  var response = await request.send();

  Navigator.of(context).pop();
  // Close the dialog programmatically
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

