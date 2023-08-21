import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modernlogintute/pages/update_victim_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/config/config.dart';
import 'package:modernlogintute/models/category_model.dart';
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
  List<Victim> _allVictims = []; // State variable to hold the list of victims
  List<Categories> _allCategories = [];
  Victim?
      _selectedVictimForEdit; // Store the victim to be edited in the modal form

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Fetch data from the API
      final response = await http.get(
        Uri.parse(Config.victimApi),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 200) {
        print("Victims Successful fetched");
        // Successful response, convert JSON to list of Victim objects
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Victim> victims = [];
        for (var json in jsonList) {
          victims.add(Victim.fromJson(json));
        }
        setState(() {
          _allVictims =
              victims; // Set the state variable with the list of victims
        });
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

  Future<void> _fetchAndPrintCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Fetch data from the API
      final response = await http.get(
        Uri.parse(Config.categoryApi),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 200) {
        print("Categories Successful fetched");
        // Successful response, convert JSON to list of Victim objects
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Categories> categories = [];
        for (var json in jsonList) {
          categories.add(Categories.fromJson(json));
        }
        setState(() {
          _allCategories =
              categories; // Set the state variable with the list of categories
        });
      } else {
        // Handle error response
        print("Failed to fetch category. Status code: ${response.statusCode}");
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
    _fetchAndPrintCategories();
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: _allVictims.isEmpty
                ? [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        'No victim yet registered',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ]
                : [
                    for (var victim in _allVictims)
                      VictimCard(
                        victim: victim,
                      ),
                  ],
          ),
        ),
      ),
    );
  }
}

// Stateless widget for the Material UI card to display each victim
class VictimCard extends StatelessWidget {
  final Victim victim;

  const VictimCard({required this.victim});

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String formattedDOB = DateFormat('dd MMMM yyyy').format(victim.dob);
        return AlertDialog(
          title: const Text("Victim Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ID: ${victim.id}"),
              const Divider(),
              Text("Last Name: ${victim.lastName}"),
              const Divider(),
              Text("First Name: ${victim.firstName}"),
              const Divider(),
              Text("DOB: ${formattedDOB}"),
              const Divider(),
              Text("Email: ${victim.email}"),
              const Divider(),
              // ... Add other properties as needed ...
              Text("Category Name: ${victim.category.categoryName}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog when 'Close' is pressed
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDOB = DateFormat('dd MMMM yyyy').format(victim.dob);
    return Card(
      child: ListTile(
        title: Text("${victim.lastName} ${victim.firstName}"),
        subtitle: Text("DOB: ${formattedDOB}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                _showDetailsDialog(
                    context); // Show the details dialog on button tap
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                int id = victim.id;
                String lastName = victim.lastName;
                String firstName = victim.firstName;
                DateTime dob = victim.dob;
                String email = victim.email;
                int categoryId = victim.category.id;
                String categoryName = victim.category.categoryName;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateVictim(
                            id: id,
                            lastName: lastName,
                            firstName: firstName,
                            dob: dob,
                            email: email,
                            categoryId: categoryId,
                            categoryName: categoryName,
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
