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

class BloodPressureState extends State<BloodPressureForm> {
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

                  BloodPressureProvider provider = BloodPressureProvider();
                  await provider.open();
                  await provider.insert(bp);
                  await provider.close();

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
