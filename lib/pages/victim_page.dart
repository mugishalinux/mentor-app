import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/my_textfield.dart';
import '../config/config.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'navBar.dart';

class VictimPage extends StatefulWidget {
  const VictimPage({Key? key}) : super(key: key);

  @override
  State<VictimPage> createState() => _VictimPageState();
}

class _VictimPageState extends State<VictimPage> {
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

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _fetchCategories();
  }

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  Future<void> fetchProvinces() async {
    final response = await http.get(Uri.parse(Config.getProvinceApi));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        provinces = data.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle API error
      print('Failed to fetch provinces');
    }
  }

  Future<void> fetchDistricts(int provinceId) async {
    final response =
        await http.get(Uri.parse('${Config.getDistrictApi}/$provinceId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        districts = data.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle API error
      print('Failed to fetch districts');
    }
  }

  void _registerUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    // Perform validation checks

    // Convert the provided date of birth to a DateTime object
    DateTime dob = DateTime.parse(dobController.text);
    // Get the current year
    DateTime now = DateTime.now();
    int currentYear = now.year;

// Calculate the age
    int age = currentYear - dob.year;
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        emailController.text.isEmpty ||
        selectedCategoryId == null ||
        selectedCategoryId == 0) {
      setState(() {
        _errorMessage = 'All fields are required.';
        isLoading = false;
      });
      return;
    }

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

    setState(() {
      isLoading = true;
      _errorMessage = '';
    });
    final registrationUrl = Config.registerVictimApi;
    final registrationBody = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "dob": dobController.text,
      "email": emailController.text,
      "user": prefs.getInt('id'), // Replace with the actual access level value
      "category": selectedCategoryId ?? 0,
    };

    final response = await http.post(
      Uri.parse(registrationUrl),
      body: json.encode(registrationBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 201) {
      // Registration successful, handle the response here if needed
      if (kDebugMode) {
        print('Registration successful');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Registration Successfully Done"),
            content:
                const Text("You have successfully registered new victim  "),
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
      // Registration failed, handle the error here if needed
      if (kDebugMode) {
        print('Registration failed');
      }
      try {
        final errorData = jsonDecode(response.body);
        print(errorData['message']);
        setState(() {
          _errorMessage = "Registration Failed ";
        });
      } catch (err) {
        print("fail to convert response");
        print("error: $err");
      }

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _errorMessage = '';
        });
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: NavBar(names: _names),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Register Victim"),
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
                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // lastname textfield
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // dob textfield with date picker
                GestureDetector(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (date != null && date != DateTime.now()) {
                      setState(() {
                        dobController.text = date.toString().split(' ')[0];
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: dobController,
                      hintText: 'Date of Birth',
                      obscureText: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // phoneNumber textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),

                // Province dropdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: DropdownButton<String>(
                    value: selectedCategory,
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
                        fetchDistricts(categoryId);
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
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  onPressed: () {
                    if (!isLoading) {
                      setState(() => isLoading = true);
                      _registerUser();
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
