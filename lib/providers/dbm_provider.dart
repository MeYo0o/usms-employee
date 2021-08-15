//This Provider will contain Camera images, firestore & storage
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DBM with ChangeNotifier {
  //Firebase Init
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firestorage = FirebaseStorage.instance;
  //UserData Container
  var userData;
  Map<String, dynamic> interviewerData = {};
  DateTime? birthDay;
  File? pickedImage;

  void updateBirthDay(DateTime newDate) {
    birthDay = newDate;
  }

  void getBirthDay() {
    birthDay = DateTime.parse(userData['birthDay']);
    notifyListeners();
  }

  // Network Image to File
  Future<void> fileFromImageUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, 'profileImage.jpg'));

    file.writeAsBytesSync(response.bodyBytes);

    pickedImage = file;
    notifyListeners();
    // return file;
  }

  void updateProfileImage(File? newImage) {
    pickedImage = newImage;
    notifyListeners();
  }

  //Image Picking Logic
  Future<File?> onImageButtonPressed(ImageSource source) async {
    final PickedFile? pickedImage = await ImagePicker().getImage(
      source: source,
      imageQuality: 100,
      maxWidth: 700,
    );
    if (pickedImage != null) {
      File? pickedFile;
      pickedFile = await ImageCropper.cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 70,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.white,
          toolbarTitle: "Crop your image",
        ),
      );
      return pickedFile;
    }
  }

  //to show scaffold message anywhere
  void hideNShowSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  //get UserData + interviewerData (if exists)
  Future<void> getUserData() async {
    //get current user
    User? user = FirebaseAuth.instance.currentUser;
    await firestore.collection('users').doc(user!.uid).get().then(
      (DocumentSnapshot snapshot) {
        userData = snapshot.data();
      },
    );
    await getInterviewerData();
    notifyListeners();
  }

  //get JobRequests
  Future<List> getJobRequests(String jobUID) async {
    List requests = [];
    await firestore.collection('jobs').doc(jobUID).get().then((DocumentSnapshot snapshot) {
      requests = snapshot.get('requests');
      // print(requests);
    });
    return requests;
  }

  //get Interviewer data , if found in your profile
  Future<void> getInterviewerData() async {
    if (userData['scheduledInterview']['interviewerId'] == '') {
      return;
    }
    await firestore
        .collection('interviewers')
        .doc(userData['scheduledInterview']['interviewerId'])
        .get()
        .then((DocumentSnapshot snapshot) {
      //if u wanna get all data
      // interviewerData = snapshot.data() as Map<String, dynamic>;

      //if u wanna get specific data
      interviewerData.addAll({
        'fullName': snapshot.get('fullName'),
        'degreeType': snapshot.get('degreeType'),
        'speciality': snapshot.get('speciality'),
      });
    });
    // return requests;
  }

  //Submit Mandatory Data
  Future<void> submitMandatoryData(
    BuildContext context,
    GlobalKey<FormState> formKey,
    // File? profileImage,
    String fullName,
    // DateTime birthDay,
    String mobileNumber,
    String address,
    String nationality,
    String religion,
    String degreeType,
    String collegeName,
    String graduationYear,
    String speciality,
    String diploma,
    bool isEditMode,
  ) async {
    //get current user
    User? user = FirebaseAuth.instance.currentUser;
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    //Data Checking
    // print(pickedImage);
    // print(birthDay);
    // print(fullName);
    // print(mobileNumber);
    // print(address);
    // print(nationality);
    // print(religion);
    // print(degreeType);
    // print(collegeName);
    // print(graduationYear);
    // print(speciality);
    // print(diploma);
    // print('Edit mode : ' + isEditMode.toString());

    if (pickedImage == null) {
      hideNShowSnackBar(context, 'Please Upload a valid Profile Image.');
      return;
    }
    if (!isValid) {
      hideNShowSnackBar(context, 'Please Complete All Required Fields.');
      return;
    }
    if (isValid) {
      //save the form then proceed to data submittion
      formKey.currentState!.save();

      //Return Function instead of stuck , ex: Network issues
      // Future.delayed(Duration(seconds: 10)).then((value) {
      //   hideNShowSnackBar(context, 'Network Error: Check your Internet Connectivity.');
      //   return;
      // });

      //upload image to firebase
      try {
        //First we make the Storage Ref. ready for uploading
        final Reference ref = firestorage.ref().child('users_images').child(user!.uid + '.jpg');

        //Second we pass the image file to the Storage Ref. to be uploaded
        await ref.putFile(pickedImage!).whenComplete(() => null);

        //Third and finally ... get the download link of that file
        final url = await ref.getDownloadURL();
        //----END of Profile Image Uploading-----//

        //submit to firestore
        await firestore.collection('users').doc(user.uid).set({
          'profileImage': url,
          'fullName': fullName,
          'mobileNumber': mobileNumber,
          'birthDay': birthDay!.toIso8601String(),
          'address': address,
          'nationality': nationality,
          'religion': religion,
          'degreeType': degreeType,
          'collegeName': collegeName,
          'graduationYear': graduationYear,
          'speciality': speciality,
          'diploma': diploma,
          'uid': user.uid,
          'verified': isEditMode ? userData['verified'] : 'unverified',
          'maritalStatus': isEditMode ? userData['maritalStatus'] : null,
          'nationalId': isEditMode ? userData['nationalId'] : null,
          'militaryStatus': isEditMode ? userData['militaryStatus'] : null,
          'expectedSalary': isEditMode ? userData['expectedSalary'] : null,
          'experiences': isEditMode ? userData['experiences'] : {},
          'personalAbilities': isEditMode ? userData['personalAbilities'] : {},
          'peopleToRefer': isEditMode ? userData['peopleToRefer'] : {},
          'appliedJob': isEditMode ? userData['appliedJob'] : '',
          'interview': isEditMode ? userData['interview'] : '',
          //new stuff
          'scheduledInterview': isEditMode
              ? userData['scheduledInterview']
              : {
                  'interviewerId': '',
                  'dayTime': '',
                  'hourTime': '',
                  'noteToCandidate': '',
                },
          'rejection': isEditMode
              ? userData['rejection']
              : {
                  'interviewerId': '',
                  'rejectionMessage': '',
                },
          'timeToApply': isEditMode ? userData['timeToApply'] : '',
        }).then((value) async {
          if (isEditMode) {
            getUserData();
            hideNShowSnackBar(context, 'Data is successfully updated!');
            return;
          }
          // else if (!isEditMode) {
          //   // Navigator.of(context).pushReplacementNamed(ProfileDataCheck.id);
          // }
        });
      } catch (err) {
        print(err);
        hideNShowSnackBar(context, 'There was an error uploading data.');
        return;
      }
    }
  }

  //Update Job Data
  Future<void> updateJobData(BuildContext context, String maritalStatus, String nationalId, String militaryStatus,
      String expectedSalary, Map experiences, Map personalAbilities, Map peopleToRefer) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      FocusScope.of(context).unfocus();
      await firestore.collection('users').doc(user!.uid).update({
        'maritalStatus': maritalStatus,
        'nationalId': nationalId,
        'militaryStatus': militaryStatus,
        'expectedSalary': expectedSalary,
        'experiences': experiences,
        'personalAbilities': personalAbilities,
        'peopleToRefer': peopleToRefer,
      }).then((_) {
        hideNShowSnackBar(context, 'Data is Uploaded Successfully.');
      });
    } catch (err) {
      hideNShowSnackBar(context, 'There was an error uploading data.');
      return;
    }
  }

  //apply job for user
  Future<void> applyForAJob(BuildContext context, String jobUID) async {
    //first check if the candidate is eligible to apply for a job (whether he has 1 day / 7 day cooldown)
    if (userData['timeToApply'] != '') {
      int timeDiffInHours = DateTime.now().difference(DateTime.parse(userData['timeToApply'])).inHours;
      int timeDiffInDays = DateTime.now().difference(DateTime.parse(userData['timeToApply'])).inDays;
      print(timeDiffInHours);
      //if the user has 1 day cooldown
      if (timeDiffInDays > 0 && timeDiffInDays <= 1) {
        //notify the user of cooldown
        hideNShowSnackBar(context, 'You can\'t apply to any job for the next $timeDiffInHours hours');
        return;
      }
      //if the user has 7 day cooldown
      if (timeDiffInDays > 0 && timeDiffInDays <= 7) {
        //notify the user of cooldown
        hideNShowSnackBar(context, 'You can\'t apply to any job for the next $timeDiffInDays days');
        return;
      }
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      // -- OLD
      //get the user jobs then add the new job to the list
      // List appliedJobs = userData['appliedJobs'];
      // appliedJobs.add(jobUID);

      //Check if the user is already applied to another job
      if (userData['appliedJob'] != '') {
        Navigator.of(context).pop();
        hideNShowSnackBar(
            context,
            'You have already applied to another job , you have to un apply from that job '
            'first.');
        return;
      }

      // -- NEW
      //get that job requests then add the user uid to that list
      List newRequests = await getJobRequests(jobUID);
      newRequests.add(userData['uid']);
      await firestore.collection('users').doc(user!.uid).update({
        'appliedJob': jobUID,
      });
      await firestore.collection('jobs').doc(jobUID).update({
        'requests': newRequests,
      }).then((_) {
        hideNShowSnackBar(context, 'Operation is done successfully.');
        Navigator.of(context).pop();
      });
    } catch (err) {
      hideNShowSnackBar(context, 'There was an error uploading data.');
      return;
    }
  }

  //delete job for user
  Future<void> unApplyForAJob(BuildContext context, String jobUID) async {
    //first check if the candidate is eligible to un-apply for a job (whether he has 1 day / 7 day cooldown)
    if (userData['timeToApply'] != '') {
      int timeDiffInHours = DateTime.now().difference(DateTime.parse(userData['timeToApply'])).inHours;
      int timeDiffInDays = DateTime.now().difference(DateTime.parse(userData['timeToApply'])).inDays;
      print(timeDiffInHours);
      //if the user has 1 day cooldown
      if (timeDiffInDays > 0 && timeDiffInDays <= 1) {
        //notify the user of cooldown
        hideNShowSnackBar(context, 'You can\'t un-apply from any job for the next $timeDiffInHours hours');
        return;
      }
      //if the user has 7 day cooldown
      if (timeDiffInDays > 0 && timeDiffInDays <= 7) {
        //notify the user of cooldown
        hideNShowSnackBar(context, 'You can\'t un-apply from any job for the next $timeDiffInDays days');
        return;
      }
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      // -- OLD
      // List appliedJobs = userData['appliedJobs'];
      // appliedJobs.remove(jobUID);
      //
      List newRequests = await getJobRequests(jobUID);
      newRequests.remove(userData['uid']);
      //
      await firestore.collection('users').doc(user!.uid).update({
        'appliedJob': '',
      });
      await firestore.collection('jobs').doc(jobUID).update({
        'requests': newRequests,
      }).then((_) {
        hideNShowSnackBar(context, 'Operation is done successfully.');
        Navigator.of(context).pop();
      });
    } catch (err) {
      hideNShowSnackBar(context, 'There was an error uploading data.');
      return;
    }
  }
}
