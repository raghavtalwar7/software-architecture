import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/manifest.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const BicycleApp());
}

class BicycleApp extends StatelessWidget {
  const BicycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bicycle Management System',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: SplashScreen(),
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterBikeScreen(),
        '/scan': (context) => const ScanBikeScreen(),
        '/report': (context) => ReportBikeScreen(),
      },
    );
  }
}
