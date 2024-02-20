import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_page.dart';

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
        canvasColor: Colors.black87,
        highlightColor: Colors.grey,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> navigateToCameraPage() async {
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(milliseconds: 500));
    // Navigate to the CameraPage
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraPage()));
  }

  @override
  Widget build(BuildContext context) {
    navigateToCameraPage();
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
