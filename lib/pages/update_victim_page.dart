import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modernlogintute/pages/update_form_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:modernlogintute/config/config.dart';
import '../components/my_textfield.dart';
import 'home_page.dart';

class UpdateVictim extends StatefulWidget {
  final int id;
  final String lastName;
  final String firstName;
  final DateTime dob;
  final String email;
  final int categoryId;
  final String categoryName;
  final String phoneNumber;

  const UpdateVictim(
      {Key? key,
      required this.id,
      required this.lastName,
      required this.firstName,
      required this.dob,
      required this.email,
      required this.categoryId,
      required this.categoryName,
      required this.phoneNumber})
      : super(key: key);

  @override
  State<UpdateVictim> createState() => _UpdateVictimState();
}

class _UpdateVictimState extends State<UpdateVictim> {
  int? _id;
  String? _jwtToken;
  String? _greeting = '';
  bool _isLoading = true;
  String _names = "";

  String firstNameController = "";
  String phoneNumberController = "";
  String lastNameController = '';
  DateTime dobController = DateTime.now();
  String emailController = '';
  String passwordController = '';
  int categoryIDent = 0;
  String? selectedCategory;
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;

  int? selectedProvinceId;
  int? selectedDistrictId;
  int? selectedSectorId;
  int? selectedCategoryId;
  bool isLoading = false;
  String _errorMessage = '';
  String _errorAgeMessage = '';

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> sectors = [];
  List<Map<String, dynamic>> categories = [];

  Future<void> _fetchCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(Config.categoryApi),
      headers: {
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data.cast<Map<String, dynamic>>();
      });
    } else {
      final responseData = json.decode(response.body);
      print("error happened : ${responseData['message']}");
      // Handle API error
      if (kDebugMode) {
        print('Failed to fetch category');
      }
    }
  }

  void _UpdateVictim() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    // Convert the provided date of birth to a DateTime object
    DateTime dob = DateTime.parse(dobController.toString());
    // Get the current year
    DateTime now = DateTime.now();
    int currentYear = now.year;

// Calculate the age
    int age = currentYear - dob.year;
    if (age >= 21) {
      print("Victim age should be below 21 years old.");
      setState(() {
        _errorAgeMessage = 'Victim age should be below 21 years old.';
        isLoading = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _errorAgeMessage = '';
        });
      });
      return;
    }

    final registrationBody = {
      "firstName": firstNameController,
      "lastName": lastNameController,
      "dob": dobController.toString(),
      "email": emailController,
      "user": prefs.getInt('id'), // Replace with the actual access level value
      "category": selectedCategoryId ?? 0,
      "phoneNumber": phoneNumberController
    };
    if (selectedCategoryId == 0 || selectedCategoryId == null) {
      selectedCategoryId = categoryIDent;
    }

    final response = await http.put(
      Uri.parse('${Config.updateVictimApi}${widget.id}'),
      body: json.encode(registrationBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
    );

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      // Registration successful, handle the response here if needed
      if (kDebugMode) {
        print('Registration successful');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Update Successfully Done"),
            content: const Text("You have updated victim  "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      Colors.black, // Set the background color to blue
                ),
                child:
                    const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
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
  void initState() {
    firstNameController = widget.firstName;
    lastNameController = widget.lastName;
    dobController = widget.dob;
    emailController = widget.email;
    categoryIDent = widget.categoryId;
    phoneNumberController = widget.phoneNumber;
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Update Victim Info"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // firstname textfield
                UpdateFormWidget(
                  hintText: 'First Name',
                  obscureText: false,
                  initialValue: widget.firstName,
                  onChanged: (value) {
                    setState(() {
                      firstNameController = value;
                    });
                  },
                  validator: (String? value) {},
                ),
                const SizedBox(height: 10),

                // lastname textfield
                UpdateFormWidget(
                  hintText: 'Last Name',
                  obscureText: false,
                  initialValue: widget.lastName,
                  onChanged: (value) {
                    setState(() {
                      lastNameController = value;
                    });
                  },
                  validator: (String? value) {},
                ),
                const SizedBox(height: 10),

                // dob textfield with date picker
                GestureDetector(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: dobController ?? widget.dob,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (date != null && date != DateTime.now()) {
                      setState(() {
                        dobController = date;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: UpdateFormWidget(
                      hintText: 'Date of Birth',
                      obscureText: false,
                      validator: (value) {},
                      onChanged: (value) {
                        setState(() {
                          dobController = DateTime.parse(value);
                        });
                      },
                      initialValue: dobController != null
                          ? dobController.toString().split(' ')[0]
                          : widget.dob.toString().split(' ')[0],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // phoneNumber textfield
                UpdateFormWidget(
                  initialValue: widget.email,
                  onChanged: (value) {
                    setState(() {
                      emailController = value;
                    });
                  },
                  hintText: 'Enter Email',
                  obscureText: false,
                  validator: (String? value) {},
                ),

                UpdateFormWidget(
                  initialValue: widget.phoneNumber,
                  onChanged: (value) {
                    setState(() {
                      phoneNumberController = value;
                    });
                  },
                  hintText: 'Enter phone number',
                  obscureText: false,
                  validator: (String? value) {},
                ),

                const SizedBox(height: 10),

                // Province dropdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: DropdownButton<String>(
                    value: widget.categoryName,

                    hint: const Text('Select Category'),
                    isExpanded: true, // Set width to 100%
                    dropdownColor:
                        Colors.white, // Set dropdown menu color to white
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value;
                        selectedCategoryId = null;
                      });
                      if (selectedCategory != null) {
                        int categoryId = categories.firstWhere((category) =>
                            category['cateogryName'] == value)['id'];
                        selectedCategoryId = categoryId;
                      }
                    },
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['cateogryName'],
                        child: Text(category['cateogryName']),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Set background color to black
                    padding: const EdgeInsets.fromLTRB(30, 18, 30, 18),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(color: Colors.white),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: Text(
                                'Please wait...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  onPressed: () {
                    if (!isLoading) {
                      setState(() => isLoading = true);
                      _UpdateVictim();
                    }
                  },
                ),

                const SizedBox(height: 8.0),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _errorAgeMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
