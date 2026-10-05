import 'package:flutter/material.dart';

class SeventhPage extends StatelessWidget {
  const SeventhPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),

      body: Center(
        child: Image.asset(
          'assets/sem.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}