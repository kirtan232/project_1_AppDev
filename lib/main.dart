import 'package:flutter/material.dart';

// The app starts here and shows the root widget.
void main() {
  runApp(const HomeFitApp());
}

// This is the root widget of HomeFit Quest.
class HomeFitApp extends StatelessWidget {
  const HomeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HomeFit Quest',
      debugShowCheckedModeBanner: false,
      // A blank screen is shown until the real screens are added.
      home: Scaffold(),
    );
  }
}
