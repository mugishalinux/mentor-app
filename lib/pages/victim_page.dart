import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        title: Text("data"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text("VICTIMS"),
          ],
        ),
      ),
    );
  }
}
