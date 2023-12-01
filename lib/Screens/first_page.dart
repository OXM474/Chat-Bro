import 'package:chat_bro/Screens/login_page.dart';
import 'package:chat_bro/Screens/register_page.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height * 0.04;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/background.jpg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chat Bro',
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Image.asset(
                      'images/logo.png',
                      width: 160,
                      height: 160,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30, left: 80, right: 80),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()));
                      },
                      child: Text('Register',
                          style: TextStyle(
                              fontSize: size, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30, left: 80, right: 80),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: MaterialButton(
                      color: Colors.white24,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: size, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
