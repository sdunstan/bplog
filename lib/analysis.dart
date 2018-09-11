import 'package:bplog/persistence.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class AnalysisPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BP Log Analysis'),
      ),
      body: AnalysisPageBody()
    );
  }

}

class AnalysisPageBody extends StatefulWidget {

  _AnalysisPageSate createState() => _AnalysisPageSate();

}

class _AnalysisPageSate extends State<AnalysisPageBody> with BloodPressureDBMixin {

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
                return SingleChildScrollView(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              "Systolic Chart",
                              style: TextStyle(fontSize: 20.0, color: Colors.black.withAlpha(170))
                          )
                        ],
                      ),
                      systolicChart(snapshot.data),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              "Diastolic Chart",
                              style: TextStyle(fontSize: 20.0, color: Colors.black.withAlpha(170))
                          )
                        ],
                      ),
                      diastolicChart(snapshot.data),
                    ],
                  )
                );
              }
          }
        }
      },
    );
  }

  Widget loadingList(String message) {
    return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[Text(message)]
    );
  }

  Widget systolicChart(List<BloodPressure> data) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        width: 500.0,
        height: 300.0,
        child:charts.TimeSeriesChart(
          _createSystolicChartData(data),
          animate: true,
          dateTimeFactory: const charts.LocalDateTimeFactory(),
      ));
  }

  Widget diastolicChart(List<BloodPressure> data) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        width: 500.0,
        height: 300.0,
        child:charts.TimeSeriesChart(
          _createDiastolicChartData(data),
          animate: true,
          dateTimeFactory: const charts.LocalDateTimeFactory(),
        ));
  }

  static List<charts.Series<BloodPressure, DateTime>> _createSystolicChartData(List<BloodPressure> bpList) {
    return [
      new charts.Series(
          id: 'Systolic',
          data: bpList,
          domainFn: (BloodPressure bp, _) => DateTime.fromMillisecondsSinceEpoch(bp.readingTime),
          measureFn: (BloodPressure bp, _) => bp.systolic)
    ];
  }

  static List<charts.Series<BloodPressure, DateTime>> _createDiastolicChartData(List<BloodPressure> bpList) {
    return [
      new charts.Series(
          id: 'Diastolic',
          data: bpList,
          domainFn: (BloodPressure bp, _) => DateTime.fromMillisecondsSinceEpoch(bp.readingTime),
          measureFn: (BloodPressure bp, _) => bp.diastolic)
    ];
  }

}



