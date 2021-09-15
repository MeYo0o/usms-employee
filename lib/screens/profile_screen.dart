import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/job_data_screen.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/jobs_screen.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      final dbm = Provider.of<DBM>(context, listen: false);
      //Rejection Message stuff
      if (dbm.userData['rejection']['interviewerId'] != '') {
        int timeToApply = DateTime.now().difference(DateTime.parse(dbm.userData['timeToApply'])).inDays;
        _showRejectionDialog(context, timeToApply);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context);
    final dbm = Provider.of<DBM>(context);

    //testing
    // print(dbm.interviewerData);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Profile',
            style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: height * 0.27,
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
                          width: width * 0.3,
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
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.04),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            dbm.userData['speciality'],
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.03),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
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
              if (dbm.userData['interview'] != 'accepted')
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
              if (dbm.userData['interview'] != 'accepted')
                ProfileTile(
                  leftText: 'Jobs Applied',
                  rightText: dbm.userData['appliedJob'] != '' ? '1' : '0',
                  rightColor: Colors.teal[400],
                ),
              if (dbm.userData['interview'] != 'accepted')
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
              if (dbm.userData['interview'] == 'accepted')
                ProfileTile(
                  leftText: 'Interviews',
                  rightText: '1',
                  tileFunc: () => _showInterviewDialog(context),
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

  void whereTo(BuildContext context) {
    final dbm = Provider.of<DBM>(context, listen: false);
    if (dbm.userData['expectedSalary'] == null) {
      Navigator.of(context).pushNamed(JobDataScreen.id);
    } else {
      Navigator.of(context).pushNamed(JobsScreen.id);
    }
  }

  Future<void> _showInterviewDialog(BuildContext context) async {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final dbm = Provider.of<DBM>(context, listen: false);
    String jobName = dbm.userData['scheduledInterview']['jobName'];
    String jobPosition = dbm.userData['scheduledInterview']['jobPosition'];
    String hourTime = dbm.userData['scheduledInterview']['hourTime'];
    String noteToCandidate = dbm.userData['scheduledInterview']['noteToCandidate'];
    DateTime dayDate = DateTime.parse(dbm.userData['scheduledInterview']['dayTime']);
    Map<String, dynamic> interviewerData = dbm.interviewerData;

    //test values
    // print(jobName);
    // print(jobPosition);
    // print(hourTime);
    // print(noteToCandidate);
    // print(dayDate);
    // print(interviewerData);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          'You got an Interview!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: dialogTile(context, '$jobName', '$jobPosition')),
            SizedBox(height: height * 0.01),
            dialogTile(context, 'Date', '${DateFormat('dd-MM-yyyy').format(dayDate)}'),
            SizedBox(height: height * 0.01),
            dialogTile(context, 'Time', '$hourTime'),
            SizedBox(height: height * 0.01),
            dialogTile(context, 'Interviewer', '${interviewerData['fullName']}.'),
            SizedBox(height: height * 0.01),
            dialogTile(context, 'Degree', '${interviewerData['degreeType']}.'),
            SizedBox(height: height * 0.01),
            dialogTile(context, 'Speciality', '${interviewerData['speciality']}.'),
            SizedBox(height: height * 0.01),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Notes',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'OtomanopeeOne',
                              fontSize: width * 0.04,
                            )),
                  ),
                  Text(noteToCandidate.replaceAll('.', '\n'),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Theme.of(context).accentColor,
                            fontFamily: 'Poppins',
                            fontSize: width * 0.042,
                          )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Acknowledged', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(fixedSize: Size(width * 0.4, height * 0.05)),
            ),
          ),
        ],
      ),
    );
  }

  RichText dialogTile(BuildContext context, String leftText, String rightText) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '$leftText : ',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'OtomanopeeOne',
                    fontSize: width * 0.04,
                  )),
          TextSpan(
              text: '$rightText',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Theme.of(context).accentColor,
                    fontFamily: 'Poppins',
                    fontSize: width * 0.042,
                  )),
        ],
      ),
    );
  }

  Future<void> _showRejectionDialog(BuildContext context, int timeToApply) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final dbm = Provider.of<DBM>(context, listen: false);
    String jobName = dbm.userData['rejection']['jobName'];
    String jobPosition = dbm.userData['rejection']['jobPosition'];
    String noteToCandidate = dbm.userData['rejection']['rejectionMessage'];
    TextStyle headText = Theme.of(context).textTheme.bodyText1!.copyWith(
          color: Theme.of(context).primaryColor,
          fontFamily: 'OtomanopeeOne',
          fontSize: width * 0.04,
        );
    TextStyle bodyText = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(color: Theme.of(context).accentColor, fontFamily: 'Poppins', fontSize: width * 0.04);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          'Sorry , you got rejected',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sorry but you got rejected from : ', style: bodyText),
            Center(
              child: Text(
                '$jobName : $jobPosition',
                style: headText,
              ),
            ),
            Text('Better Luck next time ♥', style: bodyText),
            SizedBox(height: height * 0.01),
            Text('Note that you have ${timeToApply * -1} days before you can apply to another job.', style: bodyText),
            SizedBox(height: height * 0.01),
            Text('Here is the feedback from the interviewer :', style: bodyText),
            SizedBox(height: height * 0.01),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Notes', style: headText),
                  ),
                  Text(noteToCandidate.replaceAll('.', '\n'), style: bodyText),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Acknowledged', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(fixedSize: Size(width * 0.4, height * 0.05)),
            ),
          ),
        ],
      ),
    );
  }
}
