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

import 'dart:async';

import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreenBody> {

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<BloodPressure>>(
      future: _bpList(),
      builder: (BuildContext context, AsyncSnapshot<List<BloodPressure>> snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none: return loadingList();
          case ConnectionState.waiting: return loadingList();
          default: {
            Widget list = snapshotList(snapshot.data);
            return list;
          }
        }
      },
    );
  }


  Future<List<BloodPressure>> _bpList() async {
    BloodPressureProvider provider = BloodPressureProvider();
    await provider.open();
    var data = await provider.getAll();
    provider.close();
    return data;
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
        return BPLogEntry(data[index]);
      },
          childCount: data.length
      ),
    );
  }

}

class BPLogEntry extends StatelessWidget {
  final BloodPressure _bp;

  BPLogEntry(this._bp);

  @override
  Widget build(BuildContext context) {
    double opacity = (1.0 + this._bp.diastolic.toDouble()) / 500.0;
    int sys = _bp.systolic;
    int dia = _bp.diastolic;
    Widget container = Container(
        color: Colors.red.withOpacity(opacity),
        padding: const EdgeInsets.all(12.0),
        child: Column(children: <Widget>[
            Row(
              children: <Widget>[Text(
                  DateTime.fromMicrosecondsSinceEpoch(this._bp.readingTime)
                  .toString())],
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  flex: 2,
                  child: Text("$sys / $dia",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.5)),
              Expanded(flex: 1, child: Text(this._bp.pulse.toString()))
            ])
          ])
        );

    return container;
  }
}
