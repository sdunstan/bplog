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
import 'package:intl/intl.dart';
import 'package:bplog/bp_form.dart';
import 'package:bplog/persistence.dart';
import 'package:bplog/analysis.dart';

void main() async {
  runApp(BloodPressureApp());
}

/// This is the root StatefulWidget for the application.
/// It allows us to add lifecycle events at the top level.
class BloodPressureApp extends StatefulWidget {

  @override
  BloodPressureAppState createState() => BloodPressureAppState();

}

/// The application level state.
class BloodPressureAppState extends State<BloodPressureApp> with BloodPressureDBMixin {

  @override
  void initState() {
    debugPrint("Opening database");
    openDatabase(); // mixin method proxies to a singleton
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("Cleaning up database.");
    closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Pressure Log',
      home: HomeScreen(),
      routes: <String, WidgetBuilder>{
        '/add': (BuildContext context) => BloodPressureInputPage(),
        '/analysis': (BuildContext context) => AnalysisPage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Blood Pressure Log'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.multiline_chart),
            tooltip: 'Analysis',
            onPressed: () {
              Navigator.of(context).pushNamed('/analysis');
            }
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        tooltip: 'Add blood pressure reading',
        child: new Icon(Icons.add),
      ),
      body: CustomScrollView(slivers: <Widget>[
        HomeScreenBody()
      ]),
    );
  }

}

class HomeScreenBody extends StatefulWidget {

  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreenBody> with BloodPressureDBMixin {

  @override
  Widget build(BuildContext context) {
    debugPrint("Querying records.");
    return new FutureBuilder<List<BloodPressure>>(
      future: listAll(),
      builder: (BuildContext context, AsyncSnapshot<List<BloodPressure>> snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return loadingList("Error loading list.");
        }
        else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return loadingList("loading...");
            case ConnectionState.waiting:
              return loadingList("loading...");
            default:
              {
                debugPrint("Connection state is $snapshot.connectionState");
                Widget list = snapshotList(snapshot.data);
                return list;
              }
          }
        }
      },
    );
  }

  Widget loadingList(String message) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext buildContext, int index) {
        return Text(message);
      },
          childCount: 1
      ),
    );
  }

  Widget snapshotList(List<BloodPressure> data) {
    debugPrint("Building sliver list for bp entries.");
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext buildContext, int index) {
        debugPrint("Adding index $index to list");
        if (index+1 == data.length) {
          return DismissibleBPLogEntry(data[index], bottomBorder: 75.0);
        }
        else {
          return DismissibleBPLogEntry(data[index]);
        }
      },
          childCount: data.length
      ),
    );
  }

}

class DismissibleBPLogEntry extends StatelessWidget {
  final BloodPressure _bp;
  final double bottomBorder;

  DismissibleBPLogEntry(this._bp, {this.bottomBorder = 5.0});

  @override
  Widget build(BuildContext context) {
    return Dismissible (
      key: Key(_bp.id.toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) async {
        BloodPressureDB db = BloodPressureDB();
        await db.delete(_bp.id);
      },
      background: Container(
          decoration: BoxDecoration(
              color: Colors.red,
              border: Border(
                top: BorderSide(color: Colors.grey.shade50,  width: 5.0),
                bottom: BorderSide(color: Colors.grey.shade50, width: bottomBorder),
                left: BorderSide(color: Colors.grey.shade50, width: 10.0),
              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.delete, color: Colors.white,),
              Text('Delete', style: TextStyle(color: Colors.white),),
            ],
          )),
      child: BPLogEntry(_bp, bottomBorder: this.bottomBorder)
    );
  }
}

class BPLogEntry extends StatelessWidget {
  final BloodPressure _bp;
  final double bottomBorder;
  static final DateFormat _fmt = DateFormat.yMMMEd().add_jm();

  BPLogEntry(this._bp, {this.bottomBorder = 5.0});

  @override
  Widget build(BuildContext context) {
    int sys = _bp.systolic;
    int dia = _bp.diastolic;
    DateTime bpTime = DateTime.fromMillisecondsSinceEpoch(this._bp.readingTime);

    Widget container = Container(
        decoration: BoxDecoration(
            color: Colors.teal.shade100,
            border: Border(
              top: BorderSide(color: Colors.grey.shade50, width: 5.0),
              bottom: BorderSide(color: Colors.grey.shade50, width: bottomBorder),
              left: BorderSide(color: Colors.grey.shade50, width: 10.0),
              right: BorderSide(color: Colors.grey.shade50, width: 10.0),
            )
        ),
        padding: const EdgeInsets.all(12.0),
        child: DefaultTextStyle(
            style: TextStyle(fontSize: 20.0, color: Colors.black.withAlpha(170)),
            child: Column(
            children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_fmt.format(bpTime))
              ],
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  flex: 2,
                  child: Text("$sys / $dia",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.start,
                    )
              ),
              Expanded(flex: 1,
                  child: Text(this._bp.pulse.toString(),
                    textAlign: TextAlign.end,
                    textScaleFactor: 1.5,
                  ))
            ])
          ])
        ));

    return container;
  }
}
