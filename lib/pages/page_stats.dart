import 'login_register.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:budget_tracker/models/daily.dart';
import 'package:budget_tracker/models/stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_range_form_field/date_range_form_field.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime activeDay = DateTime.now();
  String userId = "";
  int rangeDuration = 5;
  List<double> total = [];
  DateTimeRange? myDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now().add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AuthGate();
        }

        // Render your application if authenticated
        userId = snapshot.data!.uid.toString();
        return Scaffold(
          backgroundColor: grey.withOpacity(0.05),
          body: getBody(),
        );
      },
    );
  }

  Widget getBody() {
    List<charts.Series<dynamic, DateTime>> seriesList = [];
    List<TimeSeriesTotalPrice> data = [];
    List<DailyTransaction> transactions = [];

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 180));
    DateTime endDate = now.add(const Duration(days: 180));
    DateTime startSelection = DateTime(myDateRange!.start.year,
        myDateRange!.start.month, myDateRange!.start.day);
    DateTime endSelection = DateTime(
        myDateRange!.end.year, myDateRange!.end.month, myDateRange!.end.day);

    rangeDuration = myDateRange!.duration.inDays.toInt() + 1;

    Stream<QuerySnapshot> _transactionsStream = FirebaseFirestore.instance
        .collection("transactions")
        .doc(userId)
        .collection("transaction")
        .where('timeStamp',
            isGreaterThan: startSelection.millisecondsSinceEpoch.toInt())
        .where('timeStamp',
            isLessThan:
                (endSelection.millisecondsSinceEpoch.toInt() + 86400000))
        .snapshots();

    return SingleChildScrollView(
        child: Column(children: [
      //header
      Padding(
        padding:
            const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Stats",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: black),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            DateRangeField(
              firstDate: startDate,
              lastDate: endDate,
              enabled: true,
              initialValue: myDateRange,
              decoration: const InputDecoration(
                labelText: 'Date Range',
                prefixIcon: Icon(Icons.date_range),
                hintText: 'Please select a start and end date',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                myDateRange = value!;
                rangeDuration = myDateRange!.duration.inDays.toInt();
                setState(() {});
              },
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 30,
      ),
      //body
      StreamBuilder<QuerySnapshot>(
        stream: _transactionsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            debugPrint("Transactions : Connection In Progress...");
            return const LinearProgressIndicator();
          }

          if (snapshot.hasError) {
            debugPrint("Transactions : Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.hasData) {
            transactions = snapshot.data!.docs
                .map((e) =>
                    DailyTransaction.fromJson(e.data() as Map<String, dynamic>))
                .toList();
            double totalInOneDay = 0;
            int i = 1;
            data.clear();

            while (i <= rangeDuration) {
              for (var element in transactions) {
                //for each day we calculate total
                if (element.timeStamp >=
                        ((i - 1) * 86400000 +
                            myDateRange!.start.millisecondsSinceEpoch
                                .toInt()) &&
                    element.timeStamp <=
                        (i * 86400000 +
                            myDateRange!.start.millisecondsSinceEpoch
                                .toInt())) {
                  totalInOneDay =
                      totalInOneDay + element.transactionPrice.toDouble();
                }
              }
              DateTime thisDay = DateTime.fromMillisecondsSinceEpoch(
                  (i - 1) * 86400000 +
                      myDateRange!.start.millisecondsSinceEpoch.toInt());

              data.add(TimeSeriesTotalPrice(
                  DateTime(thisDay.year, thisDay.month, thisDay.day),
                  totalInOneDay));

              totalInOneDay = 0;
              i = i + 1;
            }
            seriesList.add(charts.Series<TimeSeriesTotalPrice, DateTime>(
              id: 'Total Expanse',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (TimeSeriesTotalPrice totalPrice, _) => totalPrice.time,
              measureFn: (TimeSeriesTotalPrice totalPrice, _) =>
                  totalPrice.total,
              data: data,
            ));
          }

          return SizedBox(
              height: 240,
              child: charts.TimeSeriesChart(
                seriesList,
                animate: false,
                // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                // should create the same type of [DateTime] as the data provided. If none
                // specified, the default creates local date time.
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ));
        },
      ),
    ]));
  }
}
