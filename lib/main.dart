import 'package:chat_bro/Screens/first_page.dart';
import 'package:chat_bro/firebase_options.dart';
import 'package:chat_bro/services/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_bro/Screens/home.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    getUserLoggedinStatus();
    super.initState();
  }

  getUserLoggedinStatus() async {
    await AllFunctions.getUserLoggedInStatus().then(
      (value) {
        if (value != null) {
          setState(() {
            _isLoggedIn = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: _isLoggedIn ? const Home() : const FirstPage(),
      ),
    );
  }
}
