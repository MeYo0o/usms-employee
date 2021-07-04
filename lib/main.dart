import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'screens/auth_screen.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => DBM()),
      ],
      child: MaterialApp(
        title: 'USMS Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.red,
        ),
        home: AuthScreen(),
        routes: {
          MandatorySignUpScreen.id: (context) => MandatorySignUpScreen(),
          AuthScreen.id: (context) => AuthScreen(),
        },
      ),
    );
  }
}

/*
*
StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return WelcomeScreen();
            }
            if (snapshot.hasData) {
              return MandatorySignUpScreen();
            }
            return WelcomeScreen();
          },

        )

        *
        *
        *
        * */
