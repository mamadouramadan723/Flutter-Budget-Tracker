import 'package:budget_tracker/models/user.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'login_register.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  MyUser user = MyUser("", "", "", "", "", "", "");
  String userId = "";

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
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference userRef = firestore.collection('users');

    var size = MediaQuery.of(context).size;

    return FutureBuilder<DocumentSnapshot>(
      future: userRef.doc(userId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          debugPrint("Connection In Progress...");
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          debugPrint("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          debugPrint("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          debugPrint("Document exists and data can be retrieved successfully");

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          user = MyUser(
              data["userId"],
              data["name"],
              data["dateOfBirth"],
              data["phoneNumber"],
              data["mail"],
              data["imageUrl"],
              data["creditScore"]);
        }

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
                            "Profile",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: black),
                          ),
                          Icon(AntDesign.setting)
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: (size.width - 40) * 0.4,
                            child: Stack(
                              children: [
                                RotatedBox(
                                  quarterTurns: -2,
                                  child: CircularPercentIndicator(
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      backgroundColor: grey.withOpacity(0.3),
                                      radius: 110.0,
                                      lineWidth: 6.0,
                                      percent: 0.53,
                                      progressColor: primary),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 13,
                                  child: Container(
                                    width: 85,
                                    height: 85,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                user.imageUrl.toString()),
                                            fit: BoxFit.cover)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: (size.width - 40) * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Mail : " + user.mail.toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: black.withOpacity(0.4)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Birth : " + user.phoneNumber.toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: black.withOpacity(0.4)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Birth : " + user.dateOfBirth.toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: black.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.01),
                                spreadRadius: 10,
                                blurRadius: 3,
                                // changes position of shadow
                              ),
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 25, bottom: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "United Bank Asia",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: white),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "\$2446.90",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: white),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: white)),
                                child: const Padding(
                                  padding: EdgeInsets.all(13.0),
                                  child: Text(
                                    "Update",
                                    style: TextStyle(color: white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        );
      },
    );
  }
}
