import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/victim_page.dart';
import 'package:modernlogintute/service.dart';

import 'home_page.dart';

class NavBar extends StatefulWidget {
  final String names;
  const NavBar({Key? key, required this.names}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.names,
              style: TextStyle(fontSize: 18),
            ),
            accountEmail: const Text(""),
            currentAccountPicture: Align(
              alignment: Alignment.center,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage("lib/images/userav.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text("Home"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text("Victims"),
            onTap: () => {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const VictimPage()),
                (Route<dynamic> route) => false,
              )
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app_outlined),
            title: const Text("Logout"),
            onTap: () async => {await SharedService.logout(context)},
          )
        ],
      ),
    );
  }
}
