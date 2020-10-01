import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:telegramchatapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          'Account Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nikNameTextEditingController; //nikName nguoi dung nhap
  TextEditingController
      aboutMeTextEditingController; // abloutMe nguoi dung nhap
  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageFileAvata;
  bool isLoading;
  final FocusNode nikNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //reload data from local
    reloadDataFromLocal();
  }

  void reloadDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    nickname = preferences.getString('nickname');
    aboutMe = preferences.getString('aboutMe');
    photoUrl = preferences.getString('photoUrl');
    //gan niknameEditing = nikName
    nikNameTextEditingController = TextEditingController(text: nickname);
    //gan aboutMeEditing = aboutMe
    aboutMeTextEditingController = TextEditingController(text: aboutMe);
    setState(() {});
  }

  Future getImage() async {
    File newImageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        this.imageFileAvata = newImageFile;
        isLoading = true;
      });
    }
    //up load image
    uploadImageToFireStoreAndStrorage();
  }

  Future uploadImageToFireStoreAndStrorage() async {
    String fileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvata);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownLoadUrl) {
          photoUrl = newImageDownLoadUrl;
          Firestore.instance.collection('users').document(id).updateData({
            'photoUrl': photoUrl,
            'aboutMe': aboutMe,
            'nickname': nickname,
          }).then(
            (data) async {
              await preferences.setString('photourl', photoUrl);

              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: 'Upload Successfully !');
            },
          );
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Error in getting DownLoad Url.');
        });
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (errorMsg) {
      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

// upload Data to local
  void upLoadData() {
    nikNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    Firestore.instance.collection('users').document(id).updateData({
      'photoUrl': photoUrl,
      'aboutMe': aboutMe,
      'nickname': nickname,
    }).then(
      (data) async {
        await preferences.setString('photourl', photoUrl);
        await preferences.setString('aboutMe', aboutMe);
        await preferences.setString('nickname', nickname);
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Upload Successfully !');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            margin: EdgeInsets.all(20),
            child: Center(
              child: Stack(
                children: [
                  (imageFileAvata == null)
                      ? (photoUrl != "")
                          ? Material(
                              //display alreadly existing - old image file
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lightBlueAccent),
                                  ),
                                  width: 200,
                                  height: 200,
                                  padding: EdgeInsets.all(20),
                                ),
                                imageUrl: photoUrl,
                                width: 200,
                                height: 200,
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(125),
                              ),
                              clipBehavior: Clip.hardEdge,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 90,
                              color: Colors.grey,
                            )
                      : Material(
                          //display the new upload image here
                          child: Image.file(
                            imageFileAvata,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(125),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 100,
                      color: Colors.white54.withOpacity(0.5),
                    ),
                    onPressed: getImage,
                    padding: EdgeInsets.all(0.0),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.grey,
                    iconSize: 200,
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: 10, bottom: 5, right: 10, top: 10),
                child: Text(
                  'Profile name',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(primaryColor: Colors.lightBlueAccent),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Name',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    controller: nikNameTextEditingController,
                    onChanged: (value) {
                      nickname = value;
                    },
                    focusNode: nikNameFocusNode,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: 10, bottom: 5, right: 10, top: 10),
                child: Text(
                  'About Me',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(primaryColor: Colors.lightBlueAccent),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'about',
                      contentPadding: EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    controller: aboutMeTextEditingController,
                    onChanged: (value) {
                      aboutMe = value;
                    },
                    focusNode: aboutMeFocusNode,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 50, bottom: 1),
            child: FlatButton(
              onPressed: upLoadData,
              child: Text(
                'Update',
                style: TextStyle(fontSize: 28),
              ),
              color: Colors.lightBlueAccent,
              highlightColor: Colors.grey,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: RaisedButton(
              onPressed: logoutUser,
              color: Colors.red,
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
