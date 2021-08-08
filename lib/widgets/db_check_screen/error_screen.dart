import 'package:flutter/material.dart';
import 'package:usms_mobile/screens/auth_screen.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).errorColor,
                  size: width * 0.25,
                ),
                SizedBox(height: height * 0.04),
                Text(
                  'An Error Occurred!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Try Again Later',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: height * 0.02),
                ElevatedButton(
                  child: Text('Go Back'),
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AuthScreen.id),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
