//This Provider will contain Camera images, firestore & storage
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class DBM with ChangeNotifier {
  Future<File?> onImageButtonPressed(ImageSource source) async {
    final PickedFile? pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      File? pickedFile;
      pickedFile = await ImageCropper.cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.white,
          toolbarTitle: "Crop your image",
        ),
      );
      // print("cropper ${pickedFile.runtimeType}");
      // print(pickedFile);
      return pickedFile;
    }
  }

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

  //Submit Mandatory Data
  void submitMandatoryData(
      BuildContext context,
      GlobalKey<FormState> formKey,
      File profileImage,
      String fullName,
      DateTime birthDay,
      int mobileNumber,
      String address,
      String nationality,
      String religion,
      String degreeType,
      String collegeName,
      String graduationYear,
      String speciality,
      String diploma) {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (profileImage == null) {
      hideNShowSnackBar(context, 'Please Upload A Valid Profile Picture.');
      return;
    } else if (!isValid) {
      hideNShowSnackBar(context, 'Please Complete All Required Fields.');
      return;
    }
    if (isValid) {
      formKey.currentState!.save();
    }
  }
}
