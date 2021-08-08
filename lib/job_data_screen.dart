import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/jobs_screen.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class JobDataScreen extends StatefulWidget {
  static const String id = 'job_data_screen';
  const JobDataScreen({Key? key}) : super(key: key);

  @override
  _JobDataScreenState createState() => _JobDataScreenState();
}

class _JobDataScreenState extends State<JobDataScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then(
      (_) => Future.delayed(Duration.zero).then(
        (value) {
          double width = MediaQuery.of(context).size.width;

          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(
                'Job Data Required',
                style: TextStyle(fontSize: width * 0.05),
                textAlign: TextAlign.center,
              ),
              content: Text(
                'You have to complete your profile data in order to apply for a job.\n\n'
                'Please fill the data carefully as this is one time process only!',
                style: TextStyle(fontSize: width * 0.038),
                textAlign: TextAlign.center,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('Refuse')),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('Accept')),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _maritalStatusCont.dispose();
    _nationalIdNumberCont.dispose();
    _militaryStatusCont.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _dialogFormKey = GlobalKey<FormState>();
  final TextEditingController _maritalStatusCont = TextEditingController();
  final TextEditingController _nationalIdNumberCont = TextEditingController();
  final TextEditingController _militaryStatusCont = TextEditingController();
  final TextEditingController _expectedSalaryCont = TextEditingController();
  final TextEditingController _firstCont = TextEditingController();
  final TextEditingController _secondCont = TextEditingController();
  final TextEditingController _thirdCont = TextEditingController();
  final TextEditingController _forthCont = TextEditingController();

  Map<String, List<String>> _experiences = {};
  Map<String, List<String>> _personalAbilities = {};
  Map<String, List<String>> _peopleToRefer = {};
  int _experiencesElements = 1;

  bool _isLoading = false;
  void _changeIsLoadingState() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final dbm = Provider.of<DBM>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complete Job Data'),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FormTile(
                          fieldName: 'Marital Status (Single / Married / Divorced)', controller: _maritalStatusCont),
                      FormTile(
                          fieldName: 'National ID Number (14 digits)',
                          controller: _nationalIdNumberCont,
                          inputType: TextInputType.number),
                      FormTile(
                          fieldName: 'Military Status (Completed / Postponed / Exempted)',
                          controller: _militaryStatusCont),
                      FormTile(
                          fieldName: 'Expected Salary (EGP)',
                          controller: _expectedSalaryCont,
                          inputType: TextInputType.number,
                          action: TextInputAction.done),
                      titleContainer('Experiences', width, 'Add Experiences', _experiencesDialog),
                      titleList(height, width, _experiences, 4, 'Company Name', 'Reason for Leaving',
                          thirdCell: 'Time Period', fourthRow: 'Last Salary (EGP)'),
                      titleContainer('Personal Abilities', width, 'Add Personal Abilities', _abilitiesDialog),
                      titleList(height, width, _personalAbilities, 2, 'Ability/Skill', 'Level'),
                      titleContainer('People To Refer', width, 'Add People', _peopleDialog),
                      titleList(height, width, _peopleToRefer, 3, 'Name', 'Mobile Number', thirdCell: 'Kinship'),
                      SizedBox(height: 7),
                      ElevatedButton(
                        onPressed: () async {
                          //enable loading
                          _changeIsLoadingState();
                          await dbm.updateJobData(
                              context,
                              _maritalStatusCont.text,
                              _nationalIdNumberCont.text,
                              _militaryStatusCont.text,
                              _expectedSalaryCont.text,
                              _experiences,
                              _personalAbilities,
                              _peopleToRefer);
                          //disable loading
                          _changeIsLoadingState();
                          //Navigate To Jobs Screen
                          Navigator.of(context).pushReplacementNamed(JobsScreen.id);
                        },
                        child: Text(
                          'Submit Your Data',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //Title Container
  Widget titleContainer(String title, double width, String tooltip, Future<void> dialog(BuildContext context)) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: width * 0.12),
        Container(
          width: width * 0.5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
          ),
        ),
        SizedBox(width: width * 0.1),
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: Theme.of(context).primaryColor,
            size: width * 0.11,
          ),
          onPressed: () => dialog(context).then((value) {
            setState(() {});
          }),
          alignment: Alignment.topCenter,
          tooltip: tooltip,
          splashRadius: width * 0.05,
        ),
      ],
    );
  }

  //Title List
  Container titleList(double height, double width, Map mapList, int rowSize, String firstCell, String secondCell,
      {String thirdCell = '', String fourthRow = ''}) {
    return Container(
      height: height * 0.3,
      width: width * 0.8,
      // height: _experiences.length.toDouble() + height * 0.12,
      // width: width * 0.9,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.blueGrey,
      ),
      child: ListView.separated(
        itemCount: mapList.length,
        itemBuilder: (context, i) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rowSize == 2 || rowSize == 3 || rowSize == 4) titleTile(mapList, firstCell, i),
              if (rowSize == 2 || rowSize == 3 || rowSize == 4) titleTile(mapList, secondCell, i, valueIndex: 0),
              if (rowSize == 3 || rowSize == 3 || rowSize == 4) titleTile(mapList, thirdCell, i, valueIndex: 1),
              if (rowSize == 4) titleTile(mapList, fourthRow, i, valueIndex: 2),
            ],
          );
        },
        separatorBuilder: (context, i) => Divider(
          color: Colors.yellowAccent,
          thickness: 2,
        ),
      ),
    );
  }

  //ListView Tile
  RichText titleTile(Map mapList, String leftText, int keyIndex, {int valueIndex = 100}) {
    final TextStyle leftTextStyle = Theme.of(context)
        .textTheme
        .bodyText1!
        .copyWith(fontWeight: FontWeight.bold, fontFamily: 'OtomanopeeOne', color: Colors.greenAccent);
    final TextStyle rightTextStyle =
        Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white);
    if (valueIndex == 100)
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: leftText + ' : ', style: leftTextStyle),
            TextSpan(text: mapList.keys.elementAt(keyIndex), style: rightTextStyle),
          ],
        ),
      );
    else
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: leftText + ' : ', style: leftTextStyle),
            TextSpan(text: mapList.values.elementAt(keyIndex)[valueIndex].toString(), style: rightTextStyle),
          ],
        ),
      );
  }

  RichText dialogTitle(String leftText, String rightText) {
    return RichText(
      text: TextSpan(
        children: [TextSpan(text: leftText), TextSpan(text: rightText)],
      ),
    );
  }

  //dialog
  //Experiences
  Future<void> _experiencesDialog(BuildContext context) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add Job Experiences',
            style: TextStyle(fontSize: width * 0.052),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  '1 - Add your Experiences one by one using the "Add This Job" Button.',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  '2 - When you are finished ,click the "Finish" Button',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
                  height: height * 0.42,
                  width: width * 0.8,
                  child: Form(
                    key: _dialogFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Job Experiences Added : ' + _experiences.length.toString(),
                              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.04)),
                          FormTile(fieldName: 'Company Name', controller: _firstCont),
                          FormTile(fieldName: 'Time Period (Years)', controller: _thirdCont),
                          FormTile(fieldName: 'Salary (EGP)', controller: _forthCont, inputType: TextInputType.number),
                          FormTile(fieldName: 'Reason for Leaving', controller: _secondCont),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        final bool isValid = _dialogFormKey.currentState!.validate();
                        if (isValid) {
                          setState(() {
                            _experiences.addAll({
                              _firstCont.text: [_secondCont.text, _thirdCont.text, _forthCont.text]
                            });
                          });
                          _firstCont.clear();
                          _secondCont.clear();
                          _thirdCont.clear();
                          _forthCont.clear();
                        }
                      });
                    },
                    child: Text('Add This Job')),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(primary: Theme.of(context).accentColor),
              child: Text(
                'Finish Adding Jobs',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  //Abilities
  Future<dynamic> _abilitiesDialog(BuildContext context) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          // contentPadding: EdgeInsets.all(width * 0.1),
          title: Text(
            'Add Personal Abilities',
            style: TextStyle(fontSize: width * 0.052),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  '1 - Add your Personal Abilities such as (languages/skills/courses) one by one using the "Add This '
                  'Ability" Button.',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  '2 - When you are finished ,click the "Finish" Button',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
                  height: height * 0.25,
                  width: width * 0.8,
                  child: Form(
                    key: _dialogFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Personal Abilities Added : ' + _personalAbilities.length.toString(),
                              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.04)),
                          FormTile(fieldName: 'Ability/Skill/Course', controller: _firstCont),
                          FormTile(fieldName: 'Level(Excellent/Good/Weak)', controller: _secondCont),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        final bool isValid = _dialogFormKey.currentState!.validate();
                        if (isValid) {
                          setState(() {
                            _personalAbilities.addAll({
                              _firstCont.text: [_secondCont.text]
                            });
                          });
                          _firstCont.clear();
                          _secondCont.clear();
                        }
                      });
                    },
                    child: Text('Add This Ability')),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(primary: Theme.of(context).accentColor),
              child: Text(
                'Finish Adding Abilities',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  //People
  Future<dynamic> _peopleDialog(BuildContext context) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          // contentPadding: EdgeInsets.all(width * 0.1),
          title: Text(
            'Add People to refer',
            style: TextStyle(fontSize: width * 0.052),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  '1 - Add your People one by one using the "Add This Person" Button.',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  '2 - When you are finished ,click the "Finish" Button',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
                  height: height * 0.33,
                  width: width * 0.8,
                  child: Form(
                    key: _dialogFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('People Added : ' + _peopleToRefer.length.toString(),
                              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: width * 0.04)),
                          FormTile(fieldName: 'Name', controller: _firstCont),
                          FormTile(
                              fieldName: 'Mobile Number', controller: _secondCont, inputType: TextInputType.number),
                          FormTile(
                            fieldName: 'Kinship(Father/Mother/Wife/...)',
                            controller: _thirdCont,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        final bool isValid = _dialogFormKey.currentState!.validate();
                        if (isValid) {
                          setState(() {
                            _peopleToRefer.addAll({
                              _firstCont.text: [_secondCont.text, _thirdCont.text]
                            });
                          });
                          _firstCont.clear();
                          _secondCont.clear();
                          _thirdCont.clear();
                        }
                      });
                    },
                    child: Text('Add This Person')),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(primary: Theme.of(context).accentColor),
              child: Text(
                'Finish Adding People',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
