import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/pages/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  // Error messages
  String phoneNumberError = '';
  String passwordError = '';
  bool isLoading = false;
  String _errorMessage = '';

  // sign user in method
// sign user in method
  void signUserIn() async {
    // Reset error messages
    setState(() {
      phoneNumberError = '';
      passwordError = '';
      isLoading = true;
    });

    // Perform validation
    if (phoneNumberController.text.isEmpty) {
      setState(() {
        phoneNumberError = 'Phone number cannot be empty';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password cannot be empty';
      });
      return;
    }

    // Prepare the body for the API call
    Map<String, dynamic> requestBody = {
      "phone": phoneNumberController.text,
      "password": passwordController.text,
    };

    // Perform the API call to sign-in
    final response = await http.post(
      Uri.parse(Config.loginApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    setState(() {
      isLoading = false;
    });

    // Check the API response
    if (response.statusCode == 201) {
      // Successful login, handle the response
      LoginResponseModel loginResponse = loginResponseModel(response.body);

      if (loginResponse.status == 2) {
        setState(() {
          _errorMessage = "account not activated, contact admin..";
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _errorMessage = '';
          });
        });
        return;
      } else if (loginResponse.text == "admin") {
        setState(() {
          _errorMessage = "only mentors allowed to login..";
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _errorMessage = '';
          });
        });
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await prefs.setString('token', loginResponse.jwtToken);
        await prefs.setInt('id', loginResponse.id);
        await prefs.setString('names', loginResponse.names);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }
      // Debug print the response
      if (kDebugMode) {
        print(loginResponse.toJson());
      }
    } else {
      // Handle error response
      // Display an error message or handle the error appropriately
      final errorData = jsonDecode(response.body);
      print('Error: ${response.reasonPhrase}');
      print(errorData['message']);

      setState(() {
        _errorMessage = errorData['message'];
      });
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _errorMessage = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                // welcome back, you've been missed!
                Text(
                  'Welcome back ',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: phoneNumberController,
                  hintText: 'Phone number',
                  obscureText: false,
                ),

                Visibility(
                  visible: phoneNumberError.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      phoneNumberError,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // password text-field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                Visibility(
                  visible: passwordError.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      passwordError,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  onTap: isLoading
                      ? null
                      : signUserIn, // Disable onTap when loading
                  text: 'Sign In',
                ),

                // Show circular loader when isLoading is true
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator(
                    color: Colors.black,
                  ),
                const SizedBox(height: 8.0),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        // Navigate to the RegisterPage when the text is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 50), // Add some additional padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
