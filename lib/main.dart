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

void main() {
  runApp(MaterialApp(
      title: 'Blood Pressure Log',
      home: HomeScreen(),
      routes: <String, WidgetBuilder>{
        '/add': (BuildContext context) => BloodPressureInputPage()
      }));
}

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blood Pressure Log')),
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

/*
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
            return Container(
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: BPLogEntry(index));
          }, childCount: 20),
        ),

 */

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
        switch(snapshot.connectionState) {
          case ConnectionState.none: return loadingList();
          case ConnectionState.waiting: return loadingList();
          default: {
            debugPrint("Connection state is $snapshot.connectionState");
            Widget list = snapshotList(snapshot.data);
            return list;
          }
        }
      },
    );
  }

  Widget loadingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext buildContext, int index) {
        return Text('this is neat');
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
        return DismissibleBPLogEntry(data[index]);
      },
          childCount: data.length
      ),
    );
  }

}

class DismissibleBPLogEntry extends StatelessWidget {
  final BloodPressure _bp;

  DismissibleBPLogEntry(this._bp);

  @override
  Widget build(BuildContext context) {
    return Dismissible (
      key: Key(_bp.id.toString()),
      onDismissed: (direction) async {
        BloodPressureDB db = BloodPressureDB();
        await db.delete(_bp.id);
      },
      background: Container(color: Colors.red),
      child: BPLogEntry(_bp)
    );
  }
}

class BPLogEntry extends StatelessWidget {
  final BloodPressure _bp;

  BPLogEntry(this._bp);

  @override
  Widget build(BuildContext context) {
    int sys = _bp.systolic;
    int dia = _bp.diastolic;
    DateTime bpTime = DateTime.fromMillisecondsSinceEpoch(this._bp.readingTime);
    DateFormat fmt = DateFormat.yMMMMd().add_jm();
    Widget container = Container(
        decoration: BoxDecoration(
            color: Colors.teal.shade100,
            border: Border(
              top: BorderSide(color: Colors.white, width: 10.0),
              left: BorderSide(color: Colors.white, width: 10.0),
              right: BorderSide(color: Colors.white, width: 10.0),
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
                Text(fmt.format(bpTime))
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
