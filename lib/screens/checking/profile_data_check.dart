import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/profile_screen.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';
import '../auth_screen.dart';

class ProfileDataCheck extends StatelessWidget {
  static const String id = 'profile_data_check';
  @override
  Widget build(BuildContext context) {
    final dbm = Provider.of<DBM>(context, listen: false);
    return FutureBuilder(
      future: dbm.getUserData(),
      builder: (context, userData) {
        if (userData.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (userData.hasError) {
          return ErrorScreen();
        } else if (!userData.hasData) {
          return ProfileScreen();
        }
        return AuthScreen();
      },
    );
  }
}
