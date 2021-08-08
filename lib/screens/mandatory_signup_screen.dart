import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/auth_provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/auth_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class MandatorySignUpScreen extends StatefulWidget {
  static const String id = 'mandatory_signup_screen';
  bool isEditMode = false;
  MandatorySignUpScreen({required this.isEditMode});
  @override
  _MandatorySignUpScreenState createState() => _MandatorySignUpScreenState();
}

//What's Left
/*
0 - Camera Functionality Pick/Take/Crop  ---->Done
1 - Welcome Screen for Registration , so the user doesn't freak out  ---->Done
2 - Validations  ---->Done
3 - Submit Functionality  ---->Done
4 - DB Provider that handles Submit functionality  ---->Done
5 - DB Provider should work with firestore directly ---->Done
6 - AwaitingVerification Screen Stream Builder & Navigate to MandatoryScreen || Profile Screen
---> Done
 */

class _MandatorySignUpScreenState extends State<MandatorySignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCont = TextEditingController();
  final TextEditingController _mobileCont = TextEditingController();
  final TextEditingController _addressCont = TextEditingController();
  final TextEditingController _nationalityCont = TextEditingController();
  final TextEditingController _religionCont = TextEditingController();
  final TextEditingController _degreeTypeCont = TextEditingController();
  final TextEditingController _collegeNameCont = TextEditingController();
  final TextEditingController _graduationYearCont = TextEditingController();
  final TextEditingController _specialityCont = TextEditingController();
  final TextEditingController _diplomaCont = TextEditingController();

  bool _isLoading = false;

  void _changeIsLoadingState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  //birthday widget to maintain selected birthday
  Widget birthdayWidget = BirthDayTile();

  @override
  void initState() {
    super.initState();
    if (!widget.isEditMode) {
      Future.delayed(Duration.zero).then((value) {
        double width = MediaQuery.of(context).size.width;
        final dbm = Provider.of<DBM>(context, listen: false);
        //make sure you set the profile image to null in dbm
        dbm.updateProfileImage(null);
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              'we care about you.',
              style: TextStyle(fontSize: width * 0.05),
            ),
            content: Text(
              'we need to know you better , all these data are required by our HR Team, to help '
              'you find better opportunities.',
              style: TextStyle(fontSize: width * 0.038),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(AuthScreen.id),
                      child: Text('Refuse')),
                  ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('Accept')),
                ],
              )
            ],
          ),
        );
      });
    } else if (widget.isEditMode) {
      Future.delayed(Duration.zero).then((_) async {
        final dbm = Provider.of<DBM>(context, listen: false);
        //make sure you set the profile image to null in dbm
        dbm.updateProfileImage(null);
        await dbm.getUserData();
        // await dbm.fileFromImageUrl(dbm.userData['profileImage']);
        // _birthDate = DateTime.parse(dbm.userData['birthDay']);
        _nameCont.text = dbm.userData['fullName'];
        await dbm.fileFromImageUrl(dbm.userData['profileImage']);
        dbm.getBirthDay();
        _mobileCont.text = dbm.userData['mobileNumber'];
        _addressCont.text = dbm.userData['address'];
        _nationalityCont.text = dbm.userData['nationality'];
        _religionCont.text = dbm.userData['religion'];
        _degreeTypeCont.text = dbm.userData['degreeType'];
        _collegeNameCont.text = dbm.userData['collegeName'];
        _graduationYearCont.text = dbm.userData['graduationYear'];
        _specialityCont.text = dbm.userData['speciality'];
        _diplomaCont.text = dbm.userData['diploma'];
      });
    }
  }

  @override
  void dispose() {
    _nameCont.dispose();
    _mobileCont.dispose();
    _addressCont.dispose();
    _nationalityCont.dispose();
    _religionCont.dispose();
    _degreeTypeCont.dispose();
    _collegeNameCont.dispose();
    _graduationYearCont.dispose();
    _specialityCont.dispose();
    _diplomaCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbm = Provider.of<DBM>(context);
    final auth = Provider.of<Auth>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complete Mandatory Information'),
          actions: [
            if (!widget.isEditMode)
              IconButton(
                  onPressed: () async {
                    await auth.emailSignOut();
                    // Navigator.of(context).pushReplacementNamed(AuthScreen.id);
                  },
                  icon: Icon(Icons.exit_to_app))
          ],
          // centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileImage(isEditingMode: widget.isEditMode),
                      FormTile(
                          fieldName: 'Full Name',
                          controller: _nameCont,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      widget.isEditMode ? BirthDayTile(isEditMode: true) : birthdayWidget,
                      FormTile(fieldName: 'Mobile Number', controller: _mobileCont, inputType: TextInputType.number),
                      FormTile(fieldName: 'Address', controller: _addressCont),
                      FormTile(
                          fieldName: 'Nationality',
                          controller: _nationalityCont,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      FormTile(fieldName: 'Religion', controller: _religionCont),
                      FormTile(
                          fieldName: 'College Name (ex: Cairo University)',
                          controller: _collegeNameCont,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      FormTile(
                          fieldName: 'Degree Type (ex: Art , Engineering ,...etc)',
                          controller: _degreeTypeCont,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      FormTile(
                          fieldName: 'Speciality',
                          controller: _specialityCont,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      FormTile(
                          fieldName: 'Graduation Year',
                          controller: _graduationYearCont,
                          inputType: TextInputType.number,
                          readOnlyStatus: widget.isEditMode ? true : false),
                      FormTile(
                          fieldName: 'Did you take Educational diploma? - (If Yes , mention the '
                              'speciality)',
                          controller: _diplomaCont,
                          action: TextInputAction.done),
                      SizedBox(height: 7),
                      ElevatedButton(
                        onPressed: () async {
                          //enable loading
                          _changeIsLoadingState();

                          //Check Value Testing
                          // print(_formKey);
                          // print(_pickedImage);
                          // print(_nameCont.text);
                          // print(_birthDate);
                          // print(_mobileCont.text);
                          // print(_addressCont.text);
                          // print(_nationalityCont.text);
                          // print(_religionCont.text);
                          // print(_degreeTypeCont.text);
                          // print(_collegeNameCont.text);
                          // print(_graduationYearCont.text);
                          // print(_specialityCont.text);
                          // print(_diplomaCont.text);

                          //verify & submit data
                          await dbm.submitMandatoryData(
                            context,
                            _formKey,
                            _nameCont.text,
                            _mobileCont.text,
                            _addressCont.text,
                            _nationalityCont.text,
                            _religionCont.text,
                            _degreeTypeCont.text,
                            _collegeNameCont.text,
                            _graduationYearCont.text,
                            _specialityCont.text,
                            _diplomaCont.text,
                            widget.isEditMode,
                          );
                          _changeIsLoadingState();
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
