import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:usms_mobile/providers/dbm_provider.dart';

class BirthDayTile extends StatefulWidget {
  // DateTime? birthDate;
  // BirthDayTile({this.birthDate});

  bool? isEditMode = false;
  BirthDayTile({this.isEditMode});

  @override
  _BirthDayTileState createState() => _BirthDayTileState();
}

class _BirthDayTileState extends State<BirthDayTile> {
  Future<void>? _showDatePicker(BuildContext context) async {
    final dbm = Provider.of<DBM>(context, listen: false);
    await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            initialDate: dbm.birthDay ?? DateTime(1990),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          dbm.updateBirthDay(pickedDate);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbm = Provider.of<DBM>(context);
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('Birthday : ${dbm.birthDay == null ? 'Not Set' : DateFormat('dd-MM-yyyy').format(dbm.birthDay!)}'),
          Spacer(),
          ElevatedButton(
            onPressed: widget.isEditMode == true ? null : () => _showDatePicker(context),
            child: Text('Pick Date'),
          ),
        ],
      ),
    );
  }
}
