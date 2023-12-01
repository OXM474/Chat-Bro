import 'package:chat_bro/Screens/group_info.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.userName,
      required this.groupId,
      required this.groupName});

  final String userName;
  final String groupId;
  final String groupName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  bool autofoc = false;

  @override
  void initState() {
    setState(() {
      autofoc = true;
    });
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseFunctions().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseFunctions().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).canvasColor,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfo(
                          groupId: widget.groupId,
                          groupName: widget.groupName,
                          adminName: admin),
                    ),
                  );
                },
                icon: const Icon(Icons.info)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatMessages(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.blue,
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      autofocus: autofoc,
                      focusNode: FocusNode(),
                      showCursor: true,
                      onSubmitted: (value) {
                        sendMessage();
                        setState(() {
                          autofoc = true;
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                      setState(() {
                        autofoc = true;
                      });
                    },
                    child: const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                reverse: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      groupid: widget.groupId,
                      id: snapshot.data.docs[index]['id'],
                      iscurrentuser: widget.userName ==
                          snapshot.data.docs[index]['sender']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      DatabaseFunctions()
          .sendMessage(widget.groupId, messageController.text, widget.userName);
      setState(() {
        messageController.clear();
      });
    }
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.iscurrentuser,
    required this.groupid,
    required this.id,
  });
  final String sender;
  final String message;
  final bool iscurrentuser;
  final String groupid;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          iscurrentuser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            sender,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        GestureDetector(
          onLongPress: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Delete this Message?"),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green, fontSize: 17),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        await DatabaseFunctions().deletemessage(groupid, id);
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red, fontSize: 17),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: Material(
              borderRadius: iscurrentuser
                  ? const BorderRadius.only(
                      topRight: Radius.circular(0),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
              color: iscurrentuser ? Colors.green : Colors.blue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
