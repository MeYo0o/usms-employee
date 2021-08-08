import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

import 'checking/db_check.dart';

class AuthScreen extends StatefulWidget {
  static const String id = 'auth_screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSignup = false;
  bool _isLoading = false;
  final bool _showPassword = true;
  final TextEditingController _emailCont = TextEditingController();
  final TextEditingController _passwordCont = TextEditingController();
  final TextEditingController _confirmPasswordCont = TextEditingController();

  void _changeIsLoadingState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _submitData(Auth auth, DBM dbm) async {
    FocusScope.of(context).unfocus();
    //to enable loading
    _changeIsLoadingState();
    final bool _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      dbm.hideNShowSnackBar(context, 'Please Complete All The Fields');
      //to disable loading
      _changeIsLoadingState();
    }
    if (_isValid) {
      try {
        if (_isSignup) {
          await auth.emailSignUp(_emailCont.text.trim(), _passwordCont.text);
          //to disable loading
          _changeIsLoadingState();
          //Move to mandatory Data
          // Navigator.of(context).pushReplacementNamed(DataCheckScreen.id);

        } else {
          await auth.emailSignIn(_emailCont.text.trim(), _passwordCont.text);
          //to disable loading
          _changeIsLoadingState();
          //Verify if old/new user is signing in
          // Navigator.of(context).pushReplacementNamed(DataCheckScreen.id);

        }
      } catch (err) {
        //to disable loading
        _changeIsLoadingState();
        dbm.hideNShowSnackBar(context, '${err.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _emailCont.dispose();
    _passwordCont.dispose();
    _confirmPasswordCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final dbm = Provider.of<DBM>(context, listen: false);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo-nobg.png',
                  fit: BoxFit.cover,
                  height: height * 0.3,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  height: height * 0.20,
                  width: width * 0.9,
                  child: Column(
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Ultimate School Management System',
                            // speed: Duration(milliseconds: 100),
                            // cursor: '',
                            textStyle: TextStyle(
                              fontSize: width * 0.05,
                              fontFamily: 'OtomanopeeOne',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AuthFormTile(tileName: 'Username', cont: _emailCont, obscureVar: false),
                AuthFormTile(tileName: 'Password', cont: _passwordCont, obscureVar: _showPassword),
                if (_isSignup)
                  AuthFormTile(
                    tileName: 'Confirm Password',
                    cont: _confirmPasswordCont,
                    pwCheckCont: _passwordCont,
                    obscureVar: _showPassword,
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignup = !_isSignup;
                    });
                  },
                  child: Text(
                    _isSignup
                        ? 'Already have an account? .. Click Here to Sign In'
                        : 'Don\'t have an account? .. Click Here to Sign Up',
                  ),
                ),
                ElevatedButton(
                    onPressed: () => _submitData(auth, dbm),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                          )
                        : Text(_isSignup ? 'Sign Up' : 'Sign In')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
