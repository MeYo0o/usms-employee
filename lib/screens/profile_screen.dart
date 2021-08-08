import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/job_data_screen.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/jobs_screen.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile_screen';

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context);
    final dbm = Provider.of<DBM>(context);
    //while loading profile , retrieve network url image and convert it into file saved
    // dbm.fileFromImageUrl(dbm.userData['profileImage']);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Profile',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: height * 0.25,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        child: Image.network(
                          dbm.userData['profileImage'],
                          fit: BoxFit.cover,
                          width: width * 0.4,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dbm.userData['fullName'],
                            style: Theme.of(context).textTheme.headline5!.copyWith(
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            dbm.userData['degreeType'],
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.05),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            dbm.userData['speciality'],
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.04),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ProfileTile(
                leftText: 'Account State',
                rightText: dbm.userData['verified'],
                rightColor: (dbm.userData['verified'] == 'unverified') ? Colors.red[400] : Colors.green,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: dbm.firestore.collection('jobs').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> jobsData) {
                  if (jobsData.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (jobsData.hasError) {
                    return ErrorScreen();
                  }
                  return ProfileTile(
                    leftText: 'Jobs Available',
                    rightText: jobsData.data!.docs.length.toString(),
                    rightColor: Colors.blueGrey,
                  );
                },
              ),
              ProfileTile(
                leftText: 'Jobs Applied',
                rightText: dbm.userData['appliedJob'] != '' ? '1' : '0',
                rightColor: Colors.teal[400],
              ),
              if (dbm.userData['verified'] == 'verified')
                ElevatedButton(
                  onPressed: () => dbm.userData['verified'] == 'verified'
                      ? whereTo(context)
                      : dbm.hideNShowSnackBar(context, 'You have to be verified , please wait for HR to verify you'),
                  child: Text(
                    'Apply To A Job',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Colors.white,
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width * 0.4, height * 0.05),
                  ),
                ),

              Spacer(),
              // if (dbm.userData['verified'] == 'unverified')
              ProfileTile(
                leftText: 'Edit Profile',
                rightText: 'Click Here',
                tileFunc: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => MandatorySignUpScreen(isEditMode: true),
                    ))
                    .then((_) {}),
              ),

              ElevatedButton(
                onPressed: () async {
                  await auth.emailSignOut();
                  // Navigator.of(context).pushReplacementNamed(AuthScreen.id);
                },
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.white,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(width * 0.9, height * 0.03),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //functions
  void whereTo(BuildContext context) {
    final dbm = Provider.of<DBM>(context, listen: false);
    if (dbm.userData['expectedSalary'] == null) {
      Navigator.of(context).pushNamed(JobDataScreen.id);
    } else {
      Navigator.of(context).pushNamed(JobsScreen.id);
    }
  }
}
