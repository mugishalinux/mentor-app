import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../components/square_tile.dart';
import '../models/login_response.dart';
import '../pages/login_page.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), navigateToMain);
  }

  Future<void> navigateToMain() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final String? token = preferences.getString('token');
      if (token == null) {
        print("*********************************");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        // Center the child widget
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SquareTile(imagePath: 'lib/images/google.png');
            //   Image.asset(
            //   'assets/logo.jpg',
            //   width: constraints.maxWidth * 0.5,
            //   height: constraints.maxHeight * 0.5,
            // ); // Load the logo image and set the size to 10% of the screen
          },
        ),
      ),
    );
  }
}
