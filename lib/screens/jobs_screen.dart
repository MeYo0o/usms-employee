import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/widgets/db_check_screen/error_screen.dart';

class JobsScreen extends StatelessWidget {
  static const String id = 'jobs_screen';

  @override
  Widget build(BuildContext context) {
    final dbm = Provider.of<DBM>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Available Jobs'),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: dbm.firestore.collection('jobs').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> jobsData) {
            if (jobsData.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (jobsData.hasError) {
              return ErrorScreen();
            }

            return ListView.separated(
              itemCount: jobsData.data!.docs.length,
              itemBuilder: (context, i) {
                final jobData = jobsData.data!.docs[i];
                String jobId = jobData.id;
                // bool result = dbm.userData['appliedJobs'].contains(jobId);
                return InkWell(
                  onTap: () => _jobDialog(context, jobData),
                  child: ListTile(
                    title: Text(jobData['jobName']),
                    subtitle: Text(jobData['jobPosition']),
                    trailing: Text(dbm.userData['appliedJob'] == jobId ? 'Applied' : 'Not Applied'),
                  ),
                );
              },
              separatorBuilder: (context, i) => Divider(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _jobDialog(BuildContext context, jobData) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final dbm = Provider.of<DBM>(context, listen: false);
    final String resText = jobData['jobResponsibilities'].replaceAll('.', '.\n\n');
    // print(resText);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          jobData['jobName'] + ' : ' + jobData['jobPosition'],
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Responsibilities',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: width * 0.05,
                      decoration: TextDecoration.underline,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),
              Container(
                padding: const EdgeInsets.all(20),
                height: height * 0.5,
                width: width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.amber[100],
                ),
                child: ListView(
                  children: [
                    Text(
                      resText,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: width * 0.04,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
              if (dbm.userData['appliedJob'] != (jobData['uid']))
                ElevatedButton(
                    onPressed: () => dbm.applyForAJob(context, jobData['uid'], DateTime.now().add(Duration(days: 2))),
                    child: Text('Apply')),
              if (dbm.userData['appliedJob'] == (jobData['uid']))
                ElevatedButton(
                  onPressed: () => dbm.unApplyForAJob(context, jobData['uid']),
                  child: Text('Don\'t Apply'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
