import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/config/config.dart';
import '../models/victim_modal.dart';
import 'navBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _id;
  String? _jwtToken;
  String? _greeting = '';
  bool _isLoading = true;
  String _names = "";

  Future<void> _checkUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _jwtToken = prefs.getString('token');
      _id = prefs.getInt('id');
      _names = prefs.getString('names')!;
    });
  }

  Future<void> _fetchAndPrintVictims() async {
    try {
      // Fetch data from the API
      final response = await http.get(Uri.parse(Config.victimApi));
      if (response.statusCode == 200) {
        // Successful response, convert JSON to list of Victim objects
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Victim> victims =
            jsonList.map((json) => Victim.fromJson(json)).toList();

        // Print each Victim object
        for (var victim in victims) {
          print("Victim ID: ${victim.id}");
          print("Last Name: ${victim.lastName}");
          print("First Name: ${victim.firstName}");
          // ... print other properties as needed ...
          print("Category Name: ${victim.category.categoryName}");
          print("==========================");
        }
      } else {
        // Handle error response
        print("Failed to fetch victims. Status code: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      // Handle any exceptions that may occur during the API call
      print("Error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _fetchAndPrintVictims();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("List Of Victims"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(
              height: 20,
            ),
            Text("Home"),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
