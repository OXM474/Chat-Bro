import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_bro/Screens/first_page.dart';
import 'package:chat_bro/Screens/home.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {super.key, required this.userEmail, required this.userName});
  final String userName;
  final String userEmail;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    bool lightdark = AdaptiveTheme.of(context).mode.isDark;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 60),
                  child: const Icon(
                    Icons.account_circle,
                    size: 140,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: GestureDetector(
                    onTap: () {
                      if (AdaptiveTheme.of(context).mode.isDark) {
                        setState(() {
                          AdaptiveTheme.of(context).setLight();
                          lightdark = !lightdark;
                        });
                      } else if (AdaptiveTheme.of(context).mode.isLight) {
                        setState(() {
                          AdaptiveTheme.of(context).setDark();
                          lightdark = !lightdark;
                        });
                      }
                    },
                    child: lightdark
                        ? const Icon(
                            Icons.sunny,
                            size: 32,
                            color: Color.fromARGB(255, 180, 179, 179),
                          )
                        : const Icon(
                            Icons.mode_night,
                            size: 32,
                            color: Color.fromARGB(255, 180, 179, 179),
                          ),
                  ),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              child: Text(
                widget.userName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              },
              leading: const Icon(Icons.group),
              title: Text(
                'Groups',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              onTap: () {},
              selected: true,
              selectedColor: Colors.blue,
              leading: const Icon(Icons.account_box_rounded),
              title: Text(
                'Profile',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to Logout?"),
                        actions: [
                          MaterialButton(
                            color: Colors.green,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel',
                                style: TextStyle(fontSize: 17)),
                          ),
                          MaterialButton(
                            color: Colors.red,
                            onPressed: () async {
                              await AllFunctions().signout().whenComplete(() {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FirstPage()));
                              });
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    });
              },
              leading: const Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                size: 200,
                color: Colors.grey[700],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.userName, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.userEmail, style: const TextStyle(fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
