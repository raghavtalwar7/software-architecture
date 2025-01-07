import 'package:bicycure/ui/manifest.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 4));

    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Lottie.asset(
          'assets/bike_lock_animation.json',
          width: 200, // Adjust the size if necessary
          height: 200,
          frameRate: FrameRate.max,
        ),
      ),
    );
  }
}
