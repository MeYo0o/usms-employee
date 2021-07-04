import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthDayTile extends StatefulWidget {
  DateTime birthDate = DateTime.now();
  BirthDayTile(this.birthDate);

  @override
  _BirthDayTileState createState() => _BirthDayTileState();
}

class _BirthDayTileState extends State<BirthDayTile> {
  Future<void>? _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
            context: context,
            firstDate: DateTime(1950),
            initialDate: DateTime(1990),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          widget.birthDate = pickedDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
              'Birthday : ${widget.birthDate == null ? '' : DateFormat('yyyy-MM-dd').format(widget.birthDate)}'),
          Spacer(),
          ElevatedButton(
            onPressed: () => _showDatePicker(context),
            child: Text('Pick Date'),
          ),
        ],
      ),
    );
  }
}
