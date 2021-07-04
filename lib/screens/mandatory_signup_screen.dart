import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class MandatorySignUpScreen extends StatefulWidget {
  static const String id = 'mandatory_signup_screen';
  @override
  _MandatorySignUpScreenState createState() => _MandatorySignUpScreenState();
}

//What's Left
/*

0 - Camera Functionality Pick/Take/Crop  ---->Done
1 - Welcome Screen for Registration , so the user doesn't freak out
2 - Validations
3 - Submit Functionality
4 - DB Provider that handles Submit functionality
5 - DB Provider should work with firestore directly
6 - Notifiers assembled

 */

class _MandatorySignUpScreenState extends State<MandatorySignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameCont = TextEditingController();
  DateTime _birthDate = DateTime.now();
  final TextEditingController _mobileCont = TextEditingController();
  final TextEditingController _addressCont = TextEditingController();
  final TextEditingController _nationalityCont = TextEditingController();
  final TextEditingController _religionCont = TextEditingController();
  // final TextEditingController _nationalIdCont = TextEditingController();
  final TextEditingController _degreeTypeCont = TextEditingController();
  final TextEditingController _collegeNameCont = TextEditingController();
  final TextEditingController _graduationYearCont = TextEditingController();
  final TextEditingController _specialityCont = TextEditingController();
  final TextEditingController _diplomaCont = TextEditingController();

  var profileWidget = ProfileImage();
  File? _pickedImage;

  void setProfileImageValue(File? newValue) {
    _pickedImage = newValue;
  }

  @override
  Widget build(BuildContext context) {
    final dbm = Provider.of<DBM>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complete Mandatory Information'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profileWidget,
                FormTile(fieldName: 'Full Name', controller: _nameCont),
                BirthDayTile(_birthDate),
                FormTile(
                    fieldName: 'Mobile Number',
                    controller: _mobileCont,
                    inputType: TextInputType.number),
                FormTile(fieldName: 'Address', controller: _addressCont),
                FormTile(fieldName: 'Nationality', controller: _nationalityCont),
                FormTile(fieldName: 'Religion', controller: _religionCont),
                // FormTile(
                //     fieldName: 'National-Id Number (14 digits)',
                //     controller: _nationalIdCont,
                //     inputType: TextInputType.number),
                FormTile(
                    fieldName: 'Degree Type (ex: Bachelor Degree)', controller: _degreeTypeCont),
                FormTile(fieldName: 'College Name', controller: _collegeNameCont),
                FormTile(fieldName: 'Graduation Year', controller: _graduationYearCont),
                FormTile(
                    fieldName: 'Speciality (ex:Teacher,IT,etc..)', controller: _specialityCont),
                FormTile(
                    fieldName: 'Did you take Educational diploma? - (If Yes , mention the '
                        'speciality)',
                    controller: _diplomaCont,
                    action: TextInputAction.done),
                SizedBox(height: 7),
                ElevatedButton(
                  onPressed: () {
                    _pickedImage = profileWidget.profileImage;
                    print(_pickedImage);
                  },
                  child: Text('Submit Your Data'),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
