import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/checking/db_check.dart';
import 'package:usms_mobile/screens/checking/profile_data_check.dart';
import 'package:usms_mobile/screens/jobs_screen.dart';
import 'package:usms_mobile/screens/profile_screen.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';
import 'job_data_screen.dart';
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
  //Test Bool
  final bool test = false;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => DBM()),
      ],
      child: MaterialApp(
        title: 'USMS Careers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          accentColor: Colors.black,
        ),
        home: test
            ? ProfileScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return ErrorScreen();
                  } else if (snapshot.hasData) {
                    return DataCheckScreen();
                  } else if (!snapshot.hasData) {
                    return AuthScreen();
                  }
                  return AuthScreen();
                },
              ),
        routes: {
          JobDataScreen.id: (context) => JobDataScreen(),
          JobsScreen.id: (context) => JobsScreen(),
          MandatorySignUpScreen.id: (context) =>
              MandatorySignUpScreen(isEditMode: false),
          AuthScreen.id: (context) => AuthScreen(),
          DataCheckScreen.id: (context) => DataCheckScreen(),
          ProfileDataCheck.id: (context) => ProfileDataCheck(),
          ProfileScreen.id: (context) => ProfileScreen(),
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
