import 'package:budget_tracker/json/create_budget_json.dart';
import 'package:budget_tracker/pages/page_create_profile.dart';

import 'login_register.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/models/user.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
          if (FirebaseAuth.instance.currentUser != null) {
            return const CreateProfile();
          } else {
            return const AuthGate();
          }
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

          return const CreateProfile();
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
                      top: 80, right: 20, left: 20, bottom: 25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Profile",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: black),
                          ),
                          PopupMenuButton(
                              onSelected: (result) {
                                if (result == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CreateProfile()),
                                  );
                                }
                                if (result == 3) {
                                  showAlertDialog();
                                }
                              },
                              itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text("Sign Out"),
                                      value: 1,
                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut();
                                      },
                                    ),
                                    const PopupMenuItem(
                                      child: Text("Update Pro."),
                                      value: 2,
                                    ),
                                    const PopupMenuItem(
                                      child: Text("Delete Account.",
                                          style: TextStyle(color: Colors.red)),
                                      value: 3,
                                    ),
                                  ])
                          //Icon(AntDesign.setting)
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: (size.width - 50) * 0.4,
                            child: Stack(
                              children: [
                                RotatedBox(
                                  quarterTurns: -2,
                                  child: CircularPercentIndicator(
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      backgroundColor: grey.withOpacity(0.3),
                                      radius: 50.0,
                                      lineWidth: 6.0,
                                      percent: 0.7,
                                      progressColor: primary),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: user.imageUrl != "null"
                                          ? Image.network(user.imageUrl)
                                          : Image.asset(
                                              categories[7]['icon'],
                                              fit: BoxFit.cover,
                                            ),
                                    ),
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
                                  "Mail : " + user.mail,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: black.withOpacity(0.4)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Phone Number : " + user.phoneNumber,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: black.withOpacity(0.4)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Birth : " + user.dateOfBirth,
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

  void showAlertDialog() {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        CollectionReference user =
            FirebaseFirestore.instance.collection('users');
        CollectionReference budget =
            FirebaseFirestore.instance.collection('budgets');
        CollectionReference daily =
            FirebaseFirestore.instance.collection('dailies');
        CollectionReference transaction =
            FirebaseFirestore.instance.collection('transactions');

        //delete profile
        user
            .doc(userId)
            .delete()
            .then((value) => {print("+++++User Deleted")})
            .catchError((error) => debugPrint("Failed to delete user: $error"));

        //delete budget
        budget
            .doc(userId)
            .delete()
            .then((value) => {print("+++++Budget Deleted")})
            .catchError(
                (error) => debugPrint("Failed to delete budget: $error"));

        //Daily
        daily
            .doc(userId)
            .delete()
            .then((value) => {print("+++++Daily Deleted")})
            .catchError(
                (error) => debugPrint("Failed to delete daily: $error"));

        //transaction
        transaction
            .doc(userId)
            .delete()
            .then((value) => {print("+++++Transaction Deleted")})
            .catchError(
                (error) => debugPrint("Failed to delete transaction: $error"));

        Navigator.pop(context);
        //delete user
        await FirebaseAuth.instance.currentUser!.delete();
        //sign out
        await FirebaseAuth.instance.signOut();
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Account Deletion"),
      content: const Text("Are You Sure To Delete Your Account"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
