import 'dart:async';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  const Chat({Key key, this.receiverId, this.receiverAvatar, this.receiverName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

  const ChatScreen({Key key, this.receiverId, @required this.receiverAvatar})
      : super(key: key);
  @override
  State createState() =>
      ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;
  ChatScreenState({this.receiverId, this.receiverAvatar});
  final ScrollController listScrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDisPlaySticker;
  bool isLoading;
  File imageFile;
  String imageUrl;
  String chatId;
  String id;
  var listMessage;
  SharedPreferences preferences;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    isDisPlaySticker = false;
    isLoading = false;
    chatId = '';
    readLocal();
  }

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id') ?? "";
    if (id.hashCode <= receiverId.hashCode) {
      chatId = '$id-$receiverId';
    } else {
      chatId = '$receiverId-$id';
    }
    // get
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': receiverId});
    setState(() {});
  }

  onFocusChange() {
    if (focusNode.hasFocus) {
      //an sticker khi cos nhap
      setState(() {
        isDisPlaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              //List of message
              createListMessage(),
              //show sticker
              (isDisPlaySticker ? createSticker() : Container()),
              //input text
              createInput(),
            ],
          ),
          createloading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createloading() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  Future<bool> onBackPress() async {
    if (isDisPlaySticker) {
      setState(() {
        isDisPlaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createSticker() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //list message
  createListMessage() {
    return Flexible(
      child: chatId == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(chatId)
                  .collection(chatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.lightBlueAccent),
                    ),
                  );
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, index) =>
                        createItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

//--------->isLastMsgLeft<-------------&& listMessage[index - 1]['idFrom' == id]
  bool isLastMsgLeft(int index) {
    if ((index > 0 && listMessage != null) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

//---->isLastMsgRight<-----------------&& listMessage[index - 1]['idFrom' == id]
  bool isLastMsgRight(int index) {
    if ((index > 0 && listMessage != null) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document) {
    //my message on the right
    if (document['idFrom'] == id) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          document['type'] == 0
              //text
              ? Container(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                  child: Text(
                    document['content'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              //image
              : document['type'] == 1
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullImage(
                                url: document['content'],
                              ),
                            ),
                          );
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              padding: EdgeInsets.all(70),
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.lightBlueAccent,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            imageUrl: document['content'],
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                    )

                  //sticker
                  : Container(
                      child: Image.asset(
                        'images/${document['content']}.gif',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
                    ),
        ],
      );
    }
    //recover Message on the left
    else {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLastMsgLeft(index)
                    ? Material(
                        //display receiver profile image
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            padding: EdgeInsets.all(10),
                            height: 35,
                            width: 35,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                          imageUrl: receiverAvatar,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35,
                      ),
                //---------->displayMessage<---------------
                document['type'] == 0
                    //text
                    ? Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7),
                        ),
                        margin: EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                          child: Text(
                            document['content'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImage(
                                      url: document['content'],
                                    ),
                                  ),
                                );
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    padding: EdgeInsets.all(70),
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.lightBlueAccent,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  imageUrl: document['content'],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                            margin: EdgeInsets.only(left: 10),
                          )
                        //sticker
                        : Container(
                            child: Image.asset(
                              'images/${document['content']}.gif',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMsgRight(index) ? 20 : 10,
                                right: 10),
                          ),
              ],
            ),
            //------msg time---------------
            isLastMsgLeft(index)
                ? Container(
                    margin: EdgeInsets.only(left: 50, top: 10, bottom: 5),
                    child: Text(
                      DateFormat('dd MMMM,yyyy -hh:mm:aa').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp'])),
                      ),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

//get sticker
  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isDisPlaySticker = !isDisPlaySticker;
    });
  }

//create Input Message
  createInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          //image button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: getImage,
              ),
              color: Colors.white,
            ),
          ),
          //Emoji button
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.face,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: getSticker,
              ),
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: 'Write here...',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.lightBlueAccent,
                ),
                onPressed: () => onSendMessage(textEditingController.text, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onSendMessage(String contentMsg, int type) {
    //type = 0 : text Msg
    //type = 1 : image
    //type = 2 : sticker
    if (contentMsg != '') {
      textEditingController.clear();
      var docRef = Firestore.instance
          .collection('messages')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          'idFrom': id,
          'idTo': receiverId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': contentMsg,
          'type': type,
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Cant not be send');
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      isLoading = true;
    }
    upLoadImageFile();
  }

  Future upLoadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Chat Image').child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: ' + error);
    });
  }
}
