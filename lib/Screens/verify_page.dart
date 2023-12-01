import 'package:chat_bro/Screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/background.jpg'), fit: BoxFit.cover)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 7,
                child: Image.asset('images/Email_Verify.png'),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  width: 500,
                  margin: const EdgeInsets.only(top: 20),
                  child: const Text(
                    'We have sent an link to your email to Verify your your Email and continue Registion',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 200,
                  height: 40,
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () async {
                      _isLoading = true;
                      User? currentuser = FirebaseAuth.instance.currentUser;
                      await currentuser!.reload();
                      if (currentuser.emailVerified == true) {
                        if (context.mounted) {
                          debugPrint('User is Vertified');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                          _isLoading = false;
                        }
                      } else {
                        debugPrint('User is not Vertified');
                      }
                    },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Vertified',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w400),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
