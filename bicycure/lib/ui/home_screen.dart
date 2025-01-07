import 'package:flutter/material.dart';
import 'manifest.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background for contrast
      appBar: AppBar(
        title: const Text(
          "BiCycure",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildModernButton(
              context,
              text: "Register a Bike",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterBikeScreen()));
              },
              color: Colors.green, // Bright orange for visibility
            ),
            const SizedBox(height: 20),
            _buildModernButton(
              context,
              text: "Scan a Bike",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanBikeScreen()));
              },
              color: Colors.orange[600]!, // Vibrant blue for the second button
            ),
            const SizedBox(height: 20),
            _buildModernButton(
              context,
              text: "Report a Stolen Bike",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportBikeScreen()));
              },
              color: Colors.red[600]!, // Bold red for urgency
            ),
          ],
        ),
      ),
    );
  }

  // Modern button design with rounded corners and minimalistic look
  Widget _buildModernButton(BuildContext context,
      {required String text, required VoidCallback onPressed, required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
