import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

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

  void _submitData(Auth auth, DBM dbm) {
    FocusScope.of(context).unfocus();
    final bool _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      dbm.hideNShowSnackBar(context, 'Please Complete All The Fields');
    }
    if (_isValid) {
      try {
        if (_isSignup) {
          auth.emailSignUp(_emailCont.text.trim(), _passwordCont.text);
        } else {
          auth.emailSignIn(_emailCont.text.trim(), _passwordCont.text);
        }
      } catch (err) {
        print(err);
        dbm.hideNShowSnackBar(context, '${err.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final dbm = Provider.of<DBM>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AuthFormTile(tileName: 'Email Address', cont: _emailCont, obscureVar: false),
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
                  child: Text(_isSignup
                      ? 'Already have an account? .. Click Here to Sign In'
                      : 'Don\'t have an account? .. Click Here to Sign Up'),
                ),
                ElevatedButton(
                    onPressed: () => _submitData(auth, dbm),
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(_isSignup ? 'Sign Up' : 'Sign In')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
