import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:course_poc/components/certificate_viewer.dart';
import 'package:course_poc/components/lists/completed_courses_list.dart';
import 'package:course_poc/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var badges = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  var name = "Loading...";
  var bio = "Loading...";
  String? photoURL = FirebaseAuth.instance.currentUser!.photoURL;

  @override
  void initState() {
    super.initState();
    _auth.currentUser!.reload();
    _loadUserData();
    _loadBadges();
  }

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      File _image = File(pickedFile.path);
      _storage
          .ref("profile_pictures/${_auth.currentUser!.uid}.jpg")
          .putFile(_image)
          .then((snapshot) {
        snapshot.ref.getDownloadURL().then((url) {
          _firestore.collection("users").doc(_auth.currentUser!.uid).update({
            "profilePic": url,
          }).then((snapshot) {
            _auth.currentUser!.updatePhotoURL(url);
          });
        });
      });
    }
  }

  void _loadBadges() {
    _firestore.collection("users").doc(_auth.currentUser!.uid).get().then(
      (snapshot) {
        for (var badge in snapshot.data()!["badges"]) {
          _storage.ref("badges/$badge").getDownloadURL().then((url) {
            setState(() {
              badges.add(url);
            });
          });
        }
      },
    );
  }

  void _loadUserData() {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((snapshot) {
      setState(() {
        name = snapshot.data()!["name"];
        bio = snapshot.data()!["bio"];
      });
    });
  }

  void _updateUserData() {
    _firestore.collection("users").doc(_auth.currentUser!.uid).update({
      "name": name,
      "bio": bio,
    }).then(
      ((value) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Success!"),
              content: const Text("The profile data has been updated!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok!"),
                ),
              ],
            );
          },
        );
      }),
    ).catchError((err) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Uh-Oh!"),
            content: Text("$err"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Try Again!"),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kCardPopupBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kShadowColor,
                    offset: Offset(0, 12),
                    blurRadius: 32.0,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        bottom: 32.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RawMaterialButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            constraints: const BoxConstraints(
                              minWidth: 40.0,
                              maxWidth: 40.0,
                              maxHeight: 24.0,
                            ),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Icon(
                                  Icons.arrow_back,
                                  color: kSecondaryLabelColor,
                                ),
                              ],
                            ),
                          ),
                          Text("Profile", style: kCalloutLabelStyle),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Update Your Profile"),
                                    content: Column(
                                      children: [
                                        TextField(
                                          onChanged: (newValue) {
                                            setState(
                                              () {
                                                name = newValue;
                                              },
                                            );
                                          },
                                          controller: TextEditingController(
                                            text: name,
                                          ),
                                        ),
                                        TextField(
                                          onChanged: (newValue) {
                                            setState(
                                              () {
                                                bio = newValue;
                                              },
                                            );
                                          },
                                          controller: TextEditingController(
                                            text: bio,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _updateUserData();
                                        },
                                        child: const Text("Update!"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: kShadowColor,
                                    offset: Offset(0, 12),
                                    blurRadius: 32.0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Platform.isAndroid
                                    ? Icons.edit
                                    : CupertinoIcons.pencil,
                                color: kSecondaryLabelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xFFE7EEFB),
                                    child: photoURL != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            child: Image.network(
                                              photoURL!,
                                              width: 60.0,
                                              height: 60.0,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.person),
                                    radius: 30.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kBackgroundColor,
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                ),
                              ),
                              height: 84.0,
                              width: 84.0,
                              decoration: BoxDecoration(
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFF00AEFF),
                                    Color(0xFF0076FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(42.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: kTitle2Style,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                bio,
                                style: kSecondaryCalloutLabelStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 28.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Badges",
                                  style: kHeadlineLabelStyle,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "See all",
                                      style: kSearchPlaceholderStyle,
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: kSecondaryLabelColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      height: 112.0,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: badges.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: index != 3 ? 0.0 : 20.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: kShadowColor.withOpacity(0.1),
                                  offset: const Offset(0, 12),
                                  blurRadius: 18.0,
                                ),
                              ],
                            ),
                            child: Image.network("${badges[index]}"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 20.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Certificates", style: kHeadlineLabelStyle),
                      Row(
                        children: [
                          Text("See all", style: kSearchPlaceholderStyle),
                          const Icon(
                            Icons.chevron_right,
                            color: kSecondaryLabelColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const CertificateViewer(),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Completed Courses", style: kHeadlineLabelStyle),
                      Row(
                        children: [
                          Text("See all", style: kSearchPlaceholderStyle),
                          const Icon(
                            Icons.chevron_right,
                            color: kSecondaryLabelColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const CompletedCoursesList(),
            const SizedBox(height: 28.0),
          ],
        ),
      ),
    );
  }
}
