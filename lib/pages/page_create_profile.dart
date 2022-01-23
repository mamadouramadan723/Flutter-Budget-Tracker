import 'dart:ffi';
import 'dart:io';
import 'package:budget_tracker/json/create_budget_json.dart';
import 'package:budget_tracker/pages/page_profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'login_register.dart';
import 'package:budget_tracker/models/user.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  String userId = "";
  String name = "";
  String dateOfBirth = "";
  String phoneNumber = "";
  String mail = "";
  String imageUrl = "";
  String creditScore = "";
  String birthDay = "";
  String birthMonth = "";
  String birthYear = "";
  File? _imageFile = null;

  final picker = ImagePicker();

  TextEditingController _name = TextEditingController(text: "");
  TextEditingController _phone = TextEditingController(text: "");
  TextEditingController _mail = TextEditingController(text: "");

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
        verify();

        name = "" + snapshot.data!.displayName.toString();
        dateOfBirth = "";
        phoneNumber = "" + snapshot.data!.phoneNumber.toString();
        mail = "" + snapshot.data!.email.toString();
        imageUrl = "" + snapshot.data!.photoURL.toString();

        _name = TextEditingController(text: name);
        _phone = TextEditingController(text: phoneNumber);
        _mail = TextEditingController(text: mail);

        return Scaffold(
          backgroundColor: grey.withOpacity(0.05),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text("Profile Creation"),
            actions: [
              PopupMenuButton(
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text("Sign Out"),
                          value: 1,
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ])
            ],
          ),
          body: getBody(),
        );
      },
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    PickedFile? imageFile;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: grey.withOpacity(0.15)),
                    child: Center(
                      child: _imageFile != null
                          ? Image.file(_imageFile!)
                          : Image.asset(
                              categories[7]['icon'],
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ]),

              //Name
              const SizedBox(
                height: 15,
              ),
              const Text(
                "User Name",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xff67727d)),
              ),
              TextField(
                controller: _name,
                cursorColor: black,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: black),
                decoration: const InputDecoration(
                    hintText: "Enter User Name", border: InputBorder.none),
              ),

              //Phone
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Enter Phone",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xff67727d)),
              ),
              TextField(
                controller: _phone,
                cursorColor: black,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: black),
                decoration: const InputDecoration(
                    hintText: "Enter Phone Number", border: InputBorder.none),
              ),

              //Mail
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Enter Mail",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xff67727d)),
              ),
              TextField(
                controller: _mail,
                cursorColor: black,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: black),
                decoration: const InputDecoration(
                    hintText: "Enter Mail", border: InputBorder.none),
              ),

              //Date
              const Text(
                "Enter Birthday Date",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xff67727d)),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 60),
                child: DropdownDatePicker(
                  isDropdownHideUnderline: true,
                  startYear: 1900,
                  endYear: 2025,
                  width: 10,
                  onChangedDay: (value) => {birthDay = value!},
                  onChangedMonth: (value) => {birthMonth = value!},
                  onChangedYear: (value) => {birthYear = value!},
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      name = _name.text.toString();

                      phoneNumber = _phone.text.toString();
                      mail = _mail.text.toString();
                      if (name.isEmpty ||
                          name == "null" ||
                          birthDay.isEmpty ||
                          birthMonth.isEmpty ||
                          birthYear.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Username and Birthday Date are required",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        return;
                      }
                      dateOfBirth =
                          birthDay + "/" + birthMonth + "/" + birthYear;

                      MyUser myUser = MyUser(userId, name, dateOfBirth,
                          phoneNumber, mail, imageUrl, creditScore);
                      debugPrint("-------Me : " + myUser.toJson().toString());
                      uploadProfile(myUser);
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
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> uploadProfile(MyUser myUser) async {
    DocumentReference budgetRef =
        FirebaseFirestore.instance.collection('users').doc(myUser.userId);

    await budgetRef
        .set(myUser.toJson())
        .then((value) => {setState(() {})})
        .catchError((error) => debugPrint("Failed to Upload User : $error"));
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);

      uploadImageToFirebase(context, _imageFile!);
    });
  }

  Future uploadImageToFirebase(BuildContext context, File _imageFile) async {
    String fileName = "profile_$userId";
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('profiles/$userId/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_imageFile);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => {});
    taskSnapshot.ref.getDownloadURL().then(
          (value) => {
            imageUrl = value,
          },
        );
  }

  Future <void> verify() async{
    CollectionReference user =
    FirebaseFirestore.instance.collection('users');
    user.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return const ProfilePage();
      }
    });
  }
}
