import 'package:flutter/material.dart';
import 'package:usms_mobile/widgets/widget_exporter.dart';

class FormTile extends StatelessWidget {
  final String? fieldName;
  final TextEditingController? controller;
  final TextInputType inputType;
  final TextInputAction action;
  final bool readOnlyStatus;
  FormTile({
    @required this.fieldName,
    @required this.controller,
    this.inputType = TextInputType.name,
    this.action = TextInputAction.next,
    this.readOnlyStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        key: ValueKey(fieldName),
        textInputAction: action,
        keyboardType: inputType,
        controller: controller,
        readOnly: readOnlyStatus,
        autocorrect: false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor,
            ),
          ),
          labelText: fieldName,
          labelStyle: Theme.of(context).textTheme.bodyText1,
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'This Field can\'t be empty!';
          }
          return null;
        },
      ),
    );
  }
}
