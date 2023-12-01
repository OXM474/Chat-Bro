import 'package:chat_bro/Screens/home.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});
  final String groupId;
  final String groupName;
  final String adminName;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseFunctions(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then(
      (val) {
        setState(() {
          members = val;
        });
      },
    );
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Group Info"),
        actions: [
          IconButton(
              tooltip: 'Leave this Group',
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Leave"),
                        content: const Text(
                            "Are you sure you want to leave this group? "),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 17),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              DatabaseFunctions(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName)
                                  .whenComplete(
                                () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Home(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).disabledColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).disabledColor,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Group: ${widget.groupName}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text("Admin: ${getName(widget.adminName)}"))
                      ],
                    ),
                  )
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Group Members',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                memberList(),
              ],
            )
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_box,
                        size: 50,
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Center(
                  child: Text("NO MEMBERS"),
                ),
              );
            }
          } else {
            return Container(
              margin: const EdgeInsets.only(top: 10),
              child: const Center(
                child: Text("NO MEMBERS"),
              ),
            );
          }
        } else {
          return Container(
            margin: const EdgeInsets.only(top: 10),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).disabledColor,
              ),
            ),
          );
        }
      },
    );
  }
}
