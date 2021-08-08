import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/auth_screen.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';
import 'package:usms_mobile/screens/checking/profile_data_check.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';

class DataCheckScreen extends StatelessWidget {
  static const String id = 'data_check';
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dbm = Provider.of<DBM>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: firestore.collection('users').doc(uid).snapshots(),
          builder: (context, AsyncSnapshot? snapshot) {
            if (snapshot!.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorScreen();
            }
            if (!snapshot.hasData) {
              return MandatorySignUpScreen(isEditMode: false);
            }
            if (snapshot.hasData) {
              if (!snapshot.data.exists) {
                return MandatorySignUpScreen(isEditMode: false);
              }
              if (snapshot.data.exists) {
                return ProfileDataCheck();
              }
            }
            return AuthScreen();
          },
        ),
      ),
    );
  }
}
