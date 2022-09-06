import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'camera_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera Flutter App',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          children: [
            Icon(Icons.not_started_outlined),
            Text('  Start'),
          ],
        ),
        onPressed: () {
          var mySnackBar = SnackBar(
            content: Text('wooooo'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(mySnackBar);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => CameraPage()));
        },
      ),
    );
  }
}
