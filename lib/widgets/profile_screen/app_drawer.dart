import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/auth_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final dbm = Provider.of<DBM>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Drawer(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: width * 0.2,
                child: Image.network(dbm.userData['profileImage']),
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              dbm.userData['fullName'],
              style: Theme.of(context).textTheme.headline5!.copyWith(
                    fontSize: width * 0.05,
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
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                await auth.emailSignOut();
                // Navigator.of(context).pushReplacementNamed(AuthScreen.id);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
