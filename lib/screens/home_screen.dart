import 'package:flutter/material.dart';
import 'mobile_home_screen.dart'; 
import 'web_home_screen.dart';     

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return WebHomeScreen();
        } else {
          return MobileHomeScreen();
        }
      },
    );
  }
}