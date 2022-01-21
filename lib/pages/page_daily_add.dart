import 'login_register.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:budget_tracker/models/daily.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:budget_tracker/json/create_budget_json.dart';

class PageDailyAddTransaction extends StatefulWidget {
  const PageDailyAddTransaction({Key? key}) : super(key: key);

  @override
  _PageDailyAddTransactionState createState() =>
      _PageDailyAddTransactionState();
}

class _PageDailyAddTransactionState extends State<PageDailyAddTransaction> {
  String userId = "";
  int activeCategory = 0;
  DateTime activeDay = DateTime.now();

  final TextEditingController _description = TextEditingController(text: "");
  final TextEditingController _price = TextEditingController(text: "");

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
    DateTime now = DateTime.now();
    DateTime endDate = now.add(const Duration(days: 30));
    DateTime startDate = now.subtract(const Duration(days: 30));

    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 10,
                blurRadius: 3,
                // changes position of shadow
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 60, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Create a Transaction",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                    ],
                  ),
                  CalendarTimeline(
                    initialDate: activeDay,
                    firstDate: startDate,
                    lastDate: endDate,
                    onDateSelected: (date) => {
                      activeDay = date!,
                      //if we select the toDay date then  activeDay = now
                      if (DateTime(
                              activeDay.year, activeDay.month, activeDay.day) ==
                          DateTime(now.year, now.month, now.day))
                        {activeDay = now},
                      setState(() {})
                    },
                    leftMargin: 20,
                    monthColor: Colors.blueGrey,
                    dayColor: Colors.teal[200],
                    activeDayColor: Colors.white,
                    activeBackgroundDayColor: Colors.blue,
                    dotsColor: Colors.blue,
                    locale: 'en_ISO',
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Text(
              "Choose category",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: black.withOpacity(0.5)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(categories.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    activeCategory = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        color: white,
                        border: Border.all(
                            width: 2,
                            color: activeCategory == index
                                ? primary
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: grey.withOpacity(0.01),
                            spreadRadius: 10,
                            blurRadius: 3,
                            // changes position of shadow
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, top: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: grey.withOpacity(0.15)),
                              child: Center(
                                child: Image.asset(
                                  categories[index]['icon'],
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                              )),
                          Text(
                            categories[index]['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })),
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xff67727d)),
                ),
                TextField(
                  controller: _description,
                  cursorColor: black,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: black),
                  decoration: const InputDecoration(
                      hintText: "Add Description if Needed",
                      border: InputBorder.none),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (size.width - 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Enter Price",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xff67727d)),
                          ),
                          TextField(
                            controller: _price,
                            cursorColor: black,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: black),
                            decoration: const InputDecoration(
                                hintText: "Enter Price",
                                border: InputBorder.none),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        DateFormat formatter = DateFormat.yMd().add_jm();
                        String date = formatter.format(activeDay).toString();
                        int timeStamp =
                            activeDay.millisecondsSinceEpoch.toInt();
                        String dailyId = userId + "__" + timeStamp.toString();
                        double price = 0;
                        try {
                          price = double.parse(_price.text);
                        } catch (e, s) {
                          debugPrint(e.toString() + "____" + s.toString());
                          Fluttertoast.showToast(
                              msg: "The price must be a valid Number",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          return;
                        }
                        String desc = _description.text.toString();
                        String name = categories[activeCategory]['name'];
                        String icon = categories[activeCategory]['icon'];

                        DailyTransaction transaction = DailyTransaction(userId,
                            dailyId, name, desc, date, price, timeStamp, icon);
                        uploadTransaction(transaction);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(15)),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> uploadTransaction(DailyTransaction transaction) async {
    debugPrint('+++++: Uploading.....' + transaction.toJson().toString());

    CollectionReference budgetRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(transaction.userId)
        .collection("transaction");

    await budgetRef
        .doc(transaction.transactionId)
        .set(transaction.toJson())
        .then((value) => {
              _description.clear(),
              _price.clear(),
              Fluttertoast.showToast(
                  msg: "Successfully Uploaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0),
              debugPrint("Budget Uploaded Successfully")
            })
        .catchError((error) => debugPrint("Failed to Upload Budget : $error"));
  }
}
