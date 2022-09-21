import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'camera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool ActiveConnection = false;

  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
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
        ActiveConnection = false;
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
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camera Flutter App',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Thực hành phát triển ứng dụng record Video từ Camera và Upload video lên Server',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 300,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.purple,
        tooltip: 'Camera',
        label: Row(
          children: const [
            Icon(Icons.not_started_outlined),
            Text('  Start'),
          ],
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()));
        },
      ),
    );
  }
}
