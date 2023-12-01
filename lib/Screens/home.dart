import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_bro/Screens/first_page.dart';
import 'package:chat_bro/Screens/profile_page.dart';
import 'package:chat_bro/Screens/search_page.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:chat_bro/widgets/group_tile.dart';
import 'package:chat_bro/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = '';
  String userEmail = '';
  Stream? groups;
  bool _isLoading = false;
  TextEditingController groupName = TextEditingController();

  @override
  void initState() {
    getuserdata();
    super.initState();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  void getuserdata() async {
    await DatabaseFunctions(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
    await AllFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    await AllFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        userEmail = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool lightdark = AdaptiveTheme.of(context).mode.isDark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Groups'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
                tooltip: 'Search',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()));
                },
                icon: const Icon(Icons.search)),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                userEmail: userEmail, userName: userName)));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 60),
                    child: const Icon(
                      Icons.account_circle,
                      size: 140,
                      color: Colors.grey,
                    ),
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
                userName,
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
              onTap: () {},
              selected: true,
              selectedColor: Colors.blue,
              leading: const Icon(Icons.group),
              title: Text(
                'Groups',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              userEmail: userEmail,
                              userName: userName,
                            )));
              },
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
                            await AllFunctions().signout().whenComplete(
                              () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FirstPage(),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    );
                  },
                );
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
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Group',
        onPressed: () {
          popUpGroupCreate(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).disabledColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).disabledColor,
          size: 30,
        ),
      ),
    );
  }

  popUpGroupCreate(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).disabledColor),
                        )
                      : TextField(
                          controller: groupName,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).disabledColor),
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).disabledColor),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                        color: Theme.of(context).canvasColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName.text != "") {
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseFunctions(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(
                              userName,
                              FirebaseAuth.instance.currentUser!.uid,
                              groupName.text)
                          .whenComplete(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackbar(
                          context, Colors.green, "Group created successfully.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).disabledColor),
                  child: Text(
                    "CREATE",
                    style: TextStyle(
                        color: Theme.of(context).canvasColor,
                        fontWeight: FontWeight.w400),
                  ),
                )
              ],
            );
          }));
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  List<String> curgroups =
                      List<String>.from(snapshot.data['groups']);
                  int reverseIndex = curgroups.length - index - 1;
                  return GroupTile(
                      groupId: getId(curgroups[reverseIndex]),
                      groupName: getName(curgroups[reverseIndex]),
                      userName: snapshot.data['name']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpGroupCreate(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
