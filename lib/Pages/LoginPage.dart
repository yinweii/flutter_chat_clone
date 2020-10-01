import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Pages/HomePage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isloading = false;
  FirebaseUser currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignIn();
  }

  void isSignIn() async {
    setState(() {
      isLoggedIn = true;
    });
    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(currentUserId: preferences.getString('id'))));
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.lightBlueAccent,
              Colors.purpleAccent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Flash Chat',
              style: TextStyle(
                fontSize: 70,
                fontFamily: 'Signatra',
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: controlSignin,
              child: Column(
                children: [
                  Container(
                    width: 270,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1),
                    child: isloading ? circularProgress() : Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignin() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isloading = true;
    });
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);
    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    // Sign thanh cong
    if (firebaseUser != null) {
      //check if alreadly Sign Up
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documentSnapshot = resultQuery.documents;
      //save data to firebase if new user
      if (documentSnapshot.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'aboutme': '',
          'chattingWith': null,
        });
        //write data to locall
        currentUser = firebaseUser;
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('nickname', currentUser.displayName);
        await preferences.setString('photoUrl', currentUser.uid);
      } else {
        currentUser = firebaseUser;
        await preferences.setString('id', documentSnapshot[0]['id']);
        await preferences.setString(
            'nickname', documentSnapshot[0]['nickname']);
        await preferences.setString(
            'photoUrl', documentSnapshot[0]['photoUrl']);
        await preferences.setString('aboutMe', documentSnapshot[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign Successful !");
      setState(() {
        isloading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(currentUserId: firebaseUser.uid),
        ),
      );
    }

    // Sign khong thanh thanh cong
    else {
      Fluttertoast.showToast(msg: "Try Again , Sign in faild !");
      setState(() {
        isloading = false;
      });
    }
  }
}
