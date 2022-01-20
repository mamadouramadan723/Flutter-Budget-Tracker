import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:budget_tracker/models/daily.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:progress_indicator/progress_indicator.dart';

import 'login_register.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({Key? key}) : super(key: key);

  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  DateTime activeDay = DateTime.now();
  String userId = "";
  double total = 0;

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
    var size = MediaQuery.of(context).size;

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(const Duration(days: 180));
    DateTime endDate = now.add(const Duration(days: 180));
    DateTime selectedDay =
        DateTime(activeDay.year, activeDay.month, activeDay.day);

    List<DailyTransaction> transactions = [];

    Stream<QuerySnapshot> _transactionsStream = FirebaseFirestore.instance
        .collection("transactions")
        .doc(userId)
        .collection("transaction")
        .where('timeStamp',
            isGreaterThan: selectedDay.millisecondsSinceEpoch.toInt())
        .where('timeStamp',
            isLessThan: (selectedDay.millisecondsSinceEpoch.toInt() + 86400000))
        .snapshots(includeMetadataChanges: true);

    return SingleChildScrollView(
      child: Column(
        children: [
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
                      "Daily Transaction",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: black),
                    ),
                    Icon(AntDesign.search1)
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                CalendarTimeline(
                  initialDate: activeDay,
                  firstDate: startDate,
                  lastDate: endDate,
                  onDateSelected: (date) =>
                      {activeDay = date!, setState(() {})},
                  leftMargin: 20,
                  monthColor: Colors.blueGrey,
                  dayColor: Colors.teal[200],
                  activeDayColor: Colors.white,
                  activeBackgroundDayColor: Colors.blue,
                  dotsColor: Colors.blue,
                  //selectableDayPredicate: (date) => date.day != 23,
                  locale: 'en_ISO',
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          //body
          StreamBuilder<QuerySnapshot>(
            stream: _transactionsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                //debugPrint("Transactions : Documents exist and data can be retrieved successfully");
                transactions = snapshot.data!.docs
                    .map((e) => DailyTransaction.fromJson(
                        e.data() as Map<String, dynamic>))
                    .toList();

                total = 0;
                for (var element in transactions) {
                  total = total + element.transactionPrice;
                }
              }

              return SizedBox(
                  height: 160 * (transactions.length.toDouble()),
                  child: ListView(
                      physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children:
                                List.generate(transactions.length, (index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(
                                        width: (size.width - 40) * 0.7,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: grey.withOpacity(0.1),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  transactions[index].icon,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            SizedBox(
                                              width: (size.width - 90) * 0.5,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    transactions[index]
                                                        .transactionName,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    transactions[index].date,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: black
                                                            .withOpacity(0.5),
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: (size.width - 40) * 0.3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          //this mainAxisAlignment is unnecessary when we delete "width: (size.width - 40) * 0.x"
                                          children: [
                                            Text(
                                              transactions[index]
                                                      .transactionPrice
                                                      .toString() +
                                                  " DH",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: Colors.green),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 65, top: 8),
                                    child: Divider(
                                      thickness: 0.8,
                                    ),
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                        //Footer
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20),
                          child: Row(
                            children: [
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 80),
                                child: Text(
                                  "Total",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: black.withOpacity(0.4),
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "" + total.toString() + " DH",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: black,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      ]));
            },
          ),
        ],
      ),
    );
  }
}
