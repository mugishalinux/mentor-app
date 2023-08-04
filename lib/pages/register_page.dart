import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modernlogintute/config/config.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSector;

  int? selectedProvinceId;
  int? selectedDistrictId;
  int? selectedSectorId;

  bool isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> sectors = [];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
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

  Future<void> fetchSectors(int districtId) async {
    final response =
        await http.get(Uri.parse('${Config.getSectorApi}/$districtId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        sectors = data.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle API error
      print('Failed to fetch sectors');
    }
  }

  void _registerUser() async {
    // Perform validation checks
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedProvince == null ||
        selectedDistrict == null ||
        selectedSector == null ||
        selectedProvinceId == null ||
        selectedDistrictId == null ||
        selectedSectorId == null ||
        selectedProvinceId == 0 ||
        selectedDistrictId == 0 ||
        selectedSectorId == 0) {
      setState(() {
        _errorMessage = 'All fields are required.';
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });
    final registrationUrl = Config.registerApiUser;
    final registrationBody = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "dob": dobController.text,
      "phoneNumber": phoneNumberController.text,
      "access_level": "string", // Replace with the actual access level value
      "password": passwordController.text,
      "profilePicture": "string", // Replace with the actual profile picture URL
      "province": selectedProvinceId ?? 0,
      "district": selectedDistrictId ?? 0,
      "sector": selectedSectorId ?? 0,
    };

    final response = await http.post(
      Uri.parse(registrationUrl),
      body: json.encode(registrationBody),
      headers: {'Content-Type': 'application/json'},
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
            content: const Text("You have registered successfull "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Registration Form"),
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
                  controller: phoneNumberController,
                  hintText: 'Phone Number',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Province dropdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: DropdownButton<String>(
                    value: selectedProvince,
                    hint: Text('Select Province'),
                    isExpanded: true, // Set width to 100%
                    dropdownColor:
                        Colors.white, // Set dropdown menu color to white
                    onChanged: (String? value) {
                      setState(() {
                        selectedProvince = value;
                        selectedDistrict = null;
                        selectedSector = null;
                        selectedProvinceId = null;
                        selectedDistrictId = null;
                        districts.clear();
                        sectors.clear();
                      });
                      if (selectedProvince != null) {
                        int provinceId = provinces.firstWhere(
                            (province) => province['name'] == value)['id'];
                        fetchDistricts(provinceId);
                        selectedProvinceId = provinceId;
                      }
                    },
                    items: provinces.map((province) {
                      return DropdownMenuItem<String>(
                        value: province['name'],
                        child: Text(province['name']),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // District dropdown
                if (selectedProvince != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: DropdownButton<String>(
                      value: selectedDistrict,
                      hint: Text('Select District'),
                      isExpanded: true, // Set width to 100%
                      onChanged: (String? value) {
                        setState(() {
                          selectedDistrict = value;
                          selectedSector = null;
                          selectedDistrictId = null;
                          sectors.clear();
                        });
                        if (selectedDistrict != null) {
                          int districtId = districts.firstWhere(
                              (district) => district['name'] == value)['id'];
                          fetchSectors(districtId);
                          selectedDistrictId = districtId;
                        }
                      },
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['name'],
                          child: Text(district['name']),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 10),

                // Sector dropdown
                if (selectedDistrict != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: DropdownButton<String>(
                      value: selectedSector,
                      hint: Text('Select Sector'),
                      isExpanded: true, // Set width to 100%
                      onChanged: (String? value) {
                        setState(() {
                          selectedSector = value;
                        });
                        if (selectedSector != null) {
                          int sectorId = sectors.firstWhere(
                              (sector) => sector['name'] == value)['id'];
                          fetchSectors(sectorId);
                          selectedSectorId = sectorId;
                        }
                      },
                      items: sectors.map((sector) {
                        return DropdownMenuItem<String>(
                          value: sector['name'],
                          child: Text(sector['name']),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 25),

                // register button
                // MyButton(
                //   onTap: () {
                //     _registerUser();
                //     // Implement your registration logic here
                //     print('Register button tapped!');
                //   },
                //   text: 'Register', // Change the text of the button if needed
                // ),

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
                          'Sign Up',
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

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
