/*
    bplog is an open source blood pressure log for mobile devices.
    Copyright (C) 2018 Steve Dunstan

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';
import 'package:bplog/persistence.dart';

class BloodPressureInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Pressure Log Entry"),
      ),
      body: Center(
        child: BloodPressureForm(),
      ),
    );
  }
}


class BloodPressureForm extends StatefulWidget {
  @override
  BloodPressureState createState() {
    return BloodPressureState();
  }
}

class BloodPressureState extends State<BloodPressureForm> with BloodPressureDBMixin {
  final _formKey = GlobalKey<FormState>();
  static const _insets = EdgeInsets.all(16.0);

  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();
  final TextEditingController pulseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: _insets,
            child: TextFormField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                icon: Icon(Icons.arrow_upward),
                labelText: 'Systolic',
                hintText: 'Enter systolic pressure (top number)',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter systolic pressure.';
                }
              },
            ),
          ),
          Padding(
            padding: _insets,
            child: TextFormField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                icon: Icon(Icons.arrow_downward),
                labelText: 'Diastolic',
                hintText: 'Enter diastolic pressure (bottom number)',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter diastolic pressure.';
                }
              },
            ),
          ),
          Padding(
            padding: _insets,
            child: TextFormField(
              controller: pulseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                icon: Icon(Icons.favorite_border),
                labelText: 'Pulse',
                hintText: 'Enter pulse',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter pulse.';
                }
              },
            ),
          ),
          Padding(
            padding: _insets,
            child: RaisedButton(
              onPressed: () async {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  debugPrint("Saving bp entry");
                  // If the form is valid, we want to show a Snackbar
//                  Scaffold
//                      .of(context)
//                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                  BloodPressure bp = BloodPressure();
                  bp.readingTime = DateTime.now().millisecondsSinceEpoch;
                  bp.diastolic = int.tryParse(diastolicController.text);
                  bp.systolic = int.tryParse(systolicController.text);
                  bp.pulse = int.tryParse(pulseController.text);

                  insert(bp);

                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
