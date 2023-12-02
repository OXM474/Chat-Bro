import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllFunctions {
  static String userkey = "LOGGEDINKEY";
  static String userNamekey = "USERNAMEKEY";
  static String userEmailkey = "USEREMAILKEY";

  // Save User Login

  static Future<bool> saveUserLoggedInStatus(bool isuserloggedin) async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return await spfc.setBool(userkey, isuserloggedin);
  }

  static Future<bool> saveUserEmailFromSF(String userEmail) async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return await spfc.setString(userEmailkey, userEmail);
  }

  static Future<bool> saveUserNameFromSF(String userName) async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return await spfc.setString(userNamekey, userName);
  }

  // Get User Login

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return spfc.getBool(userkey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return spfc.getString(userEmailkey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences spfc = await SharedPreferences.getInstance();
    return spfc.getString(userNamekey);
  }

  Future signout() async {
    try {
      await AllFunctions.saveUserLoggedInStatus(false);
      await AllFunctions.saveUserEmailFromSF('');
      await AllFunctions.saveUserNameFromSF('');
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      return null;
    }
  }
}

class DatabaseFunctions {
  final String? uid;
  DatabaseFunctions({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollections =
      FirebaseFirestore.instance.collection("groups");

  Future savingUserData(String name, String email) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'groups': [],
      'uid': uid,
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollections.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      'time': FieldValue.serverTimestamp(),
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  getChats(String groupId) async {
    return groupCollections
        .doc(groupId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollections.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  getGroupMembers(groupId) async {
    return groupCollections.doc(groupId).snapshots();
  }

  searchByName(String groupName) {
    return groupCollections.where("groupName", isEqualTo: groupName).get();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollections.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage(String groupId, String text, String userName) async {
    DocumentReference messageDocumentReference =
        await groupCollections.doc(groupId).collection('messages').add({
      "message": text,
      "sender": userName,
      "time": FieldValue.serverTimestamp(),
      'id': '',
    });

    await messageDocumentReference.update({
      "id": messageDocumentReference.id,
    });
  }

  Future deletemessage(String groupId, String id) async {
    await groupCollections
        .doc(groupId)
        .collection("messages")
        .doc(id)
        .delete()
        .then(
          (doc) => debugPrint("Document deleted"),
          onError: (e) => debugPrint("Error updating document $e"),
        );
  }
}
