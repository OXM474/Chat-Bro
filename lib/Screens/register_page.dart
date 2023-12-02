import 'package:chat_bro/Screens/home.dart';
import 'package:chat_bro/Screens/login_page.dart';
import 'package:chat_bro/Screens/verify_page.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:chat_bro/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController useremail = TextEditingController();
  TextEditingController userpass = TextEditingController();
  TextEditingController confirmuserpass = TextEditingController();
  TextEditingController username = TextEditingController();

  bool hidepw = true;
  bool hidepw1 = true;
  bool _isLoading = false;
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
                      autofocus: true,
                      cursorColor: Colors.blue,
                      controller: username,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'User Name',
                        hintText: 'Enter Your Name',
                        prefixIcon: const Icon(Icons.account_box_rounded),
                      ),
                    ),
                  ),
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
                    margin: const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: TextField(
                      cursorColor: Colors.blue,
                      controller: confirmuserpass,
                      obscureText: hidepw1,
                      obscuringCharacter: '●',
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Confirm Password',
                        hintText: 'Enter Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: Container(
                          margin: const EdgeInsets.only(right: 7),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                hidepw1 = !hidepw1;
                              });
                            },
                            child: hidepw1
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
                          _isLoading = true;
                        });
                        if (userpass.text == confirmuserpass.text) {
                          try {
                            UserCredential cre = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: useremail.text,
                                    password: userpass.text);
                            debugPrint('$cre');
                            final user = cre.user!;
                            await DatabaseFunctions(uid: user.uid)
                                .savingUserData(username.text, useremail.text);
                            await user.sendEmailVerification();
                            await AllFunctions.saveUserEmailFromSF(
                                useremail.text);
                            await AllFunctions.saveUserLoggedInStatus(true);
                            await AllFunctions.saveUserNameFromSF(
                                username.text);
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyPage()));
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              debugPrint('The password provided is too weak.');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Password is too Short ! Try Another',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(milliseconds: 2000),
                                ));
                              }
                            } else if (e.code == 'email-already-in-use') {
                              debugPrint(
                                  'The account already exists for that email.');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'The account already exists for that email!',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(milliseconds: 2000),
                                ));
                              }
                            } else if (e.code == 'invalid-email') {
                              debugPrint('Invalid Email');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Please Enter a correct Email !',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(milliseconds: 2000),
                                ));
                              }
                            } else {
                              debugPrint(e.code);
                            }
                          } catch (e) {
                            debugPrint('$e');
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
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              'Passwords are not Match',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(milliseconds: 2000),
                          ));
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an Account ?"),
                            MaterialButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()));
                                },
                                child: const Text('Login here')),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
