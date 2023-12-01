import 'package:chat_bro/Screens/home.dart';
import 'package:chat_bro/Screens/register_page.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:chat_bro/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController useremail = TextEditingController();
  TextEditingController userpass = TextEditingController();
  bool hidepw = true;
  bool isLoading = false;
  late String errormessage;

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential googlecredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    await DatabaseFunctions(uid: googlecredential.user!.uid).savingUserData(
        googlecredential.user!.displayName!, googlecredential.user!.email!);
    await AllFunctions.saveUserLoggedInStatus(true);
    await AllFunctions.saveUserEmailFromSF(googlecredential.user!.email!);
    await AllFunctions.saveUserNameFromSF(googlecredential.user!.displayName!);
    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }

  Future signInWithGoogleweb() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
    UserCredential googlecredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
    await DatabaseFunctions(uid: googlecredential.user!.uid).savingUserData(
        googlecredential.user!.displayName!, googlecredential.user!.email!);
    await AllFunctions.saveUserLoggedInStatus(true);
    await AllFunctions.saveUserEmailFromSF(googlecredential.user!.email!);
    await AllFunctions.saveUserNameFromSF(googlecredential.user!.displayName!);
    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/background.jpg'), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text(
                    'Chat Bro',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    'images/logo.png',
                    width: 160,
                    height: 160,
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: TextField(
                      cursorColor: Colors.blue,
                      controller: useremail,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Email',
                        hintText: 'Enter Your Email',
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: TextField(
                      cursorColor: Colors.blue,
                      controller: userpass,
                      obscureText: hidepw,
                      obscuringCharacter: '●',
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Password',
                        hintText: 'Enter Your Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: Container(
                          margin: const EdgeInsets.only(right: 7),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                hidepw = !hidepw;
                              });
                            },
                            child: hidepw
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30, left: 80, right: 80),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: MaterialButton(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Colors.blue,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          UserCredential cre = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: useremail.text,
                                  password: userpass.text);
                          debugPrint('$cre');
                          QuerySnapshot snapshot = await DatabaseFunctions(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .getUserData(useremail.text);
                          await AllFunctions.saveUserLoggedInStatus(true);
                          await AllFunctions.saveUserEmailFromSF(
                              useremail.text);
                          await AllFunctions.saveUserNameFromSF(
                              snapshot.docs[0]['name']);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            debugPrint('No user found for that email.');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'Email not Found !',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 2000),
                              ));
                            }
                          } else if (e.code == 'wrong-password') {
                            debugPrint(
                                'Wrong password provided for that user.');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'Wrong Password !',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 2000),
                              ));
                            }
                          } else if (e.code == 'invalid-login-credentials') {
                            debugPrint('This Email have not Register');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'Email have not Register !',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 2000),
                              ));
                            }
                          } else {
                            debugPrint(e.code);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'Something Wrong!',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(milliseconds: 2000),
                              ));
                            }
                          }
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an Account ?"),
                        MaterialButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage()));
                            },
                            child: const Text('Register here'))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: MaterialButton(
                      onPressed: () async {
                        if (kIsWeb) {
                          await signInWithGoogleweb();
                        } else {
                          await signInWithGoogle();
                        }
                      },
                      child: Image.asset(
                        'images/google-logo.jpg',
                        width: 100,
                        height: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
