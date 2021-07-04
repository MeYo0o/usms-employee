import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';
import 'package:usms_mobile/screens/mandatory_signup_screen.dart';

class ProfileImage extends StatefulWidget {
  File? profileImage;

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  Future<File?> _pickImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Pick a Profile Picture'),
            content: Text('Choose how you want to upload a picture of your self. ♥'),
            elevation: 8,
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        DBM().onImageButtonPressed(ImageSource.camera).then((croppedImage) {
                      setState(() {
                        widget.profileImage = croppedImage;
                      });
                    }),
                    child: Text('Camera'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        DBM().onImageButtonPressed(ImageSource.gallery).then((croppedImage) {
                      setState(() {
                        widget.profileImage = croppedImage;
                      });
                      Navigator.of(ctx).pop();
                    }),
                    child: Text('Gallery'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.profileImage != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      child: Image.file(
                        widget.profileImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      child: Image.asset(
                        'assets/images/image_placeHolder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          ElevatedButton(
              onPressed: () {
                _pickImage(context);
              },
              child: Text('Pick Profile Image')),
        ],
      ),
    );
  }
}
