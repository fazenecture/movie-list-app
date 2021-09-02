import 'package:flutter/gestures.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movist_app/movie_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:movist_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class AddMovie extends StatefulWidget {
  static String id = 'add_moive';




  @override
  _AddMovieState createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late User user;
  var dbRef = FirebaseDatabase.instance.reference();
  TextEditingController movieTitle = TextEditingController();
  TextEditingController directorName = TextEditingController();
  TextEditingController movieDesc = TextEditingController();

  UploadTask? task;
  File? file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _firebaseAuth.currentUser!;
  }

  final ImagePicker _picker = ImagePicker();
  var imageUrl;

  // Future selectFile() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   setState(() {
  //     file = File(pickedFile!.path);
  //   });
  // }

  Future uploadImageToFirebase() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = File(pickedFile!.path);
    });

    String fileName = basename(file!.path);

    print('eee');

    final firebaseStorage = FirebaseStorage.instance
        .ref()
        .child('uploads/${user.uid}/$fileName')
        .putFile(file!);

    final taskSnapshot = await firebaseStorage.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
      Fluttertoast.showToast(
        msg: 'Image Uploaded',
        textColor: Color(0xFFFFB43A),
        backgroundColor: Color(0xFF272833).withOpacity(0.8),
      );
    });
  }

  late double sValue = 0;

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    var userid = user.uid;
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          visible: !keyboardIsOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Hero(
              tag: 'stob',
              child: MaterialButton(
                onPressed: () {
                  try {
                    print(imageUrl);
                    if(imageUrl != ''){
                      if (sValue != 0 &&
                          movieTitle.text.isNotEmpty &&
                          directorName.text.isNotEmpty &&
                          movieDesc.text.isNotEmpty) {
                        dbRef.child('${user.uid}/Movies/${movieTitle.text}').set({
                          "Title": movieTitle.text,
                          "Director": directorName.text,
                          "Desc": movieDesc.text,
                          "Rating": sValue,
                          "ImageUrl": imageUrl,
                        });
                        Navigator.pushReplacementNamed(context, MovieList.id);
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Fields Empty',
                          textColor: Color(0xFFFFB43A),
                          backgroundColor: Color(0xFF272833).withOpacity(0.8),
                        );
                      }
                    } else{
                      Fluttertoast.showToast(
                          msg: 'Image Not Uploaded\nPlease wait',
                          textColor: Color(0xFFFFB43A),
                          backgroundColor: Color(0xFF272833).withOpacity(0.8),
                      );
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                      textColor: Color(0xFFFFB43A),
                      backgroundColor: Color(0xFF272833).withOpacity(0.8),
                    );
                  }
                },
                height: 50,
                // elevation: 0,
                minWidth: double.infinity,
                //padding: EdgeInsets.all(2),
                //textColor: Colors.white,
                color: kYellow,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  'Add This Movie',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: kBackColor,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: uploadImageToFirebase,
                child: Stack(
                  children: [
                    file != null
                        ? Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                              image: DecorationImage(
                                image: FileImage(
                                  file!,
                                ),
                                // image:
                                //     imageUrl != null ? NetworkImage('imageUrl') : NetworkImage('https://picsum.photos/250?image=9'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: kSecondColor,
                                  size: 140,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'TAP TO\nUPLOAD AN IMAGE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                          gradient: LinearGradient(
                              colors: [
                            kBackColor.withOpacity(0.2),
                            kBackColor
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingStars(
                      value: sValue,
                      onValueChanged: (v) {
                        setState(() {
                          sValue = v;
                        });
                        print(sValue);
                      },
                      starBuilder: (index, color) => Icon(
                        Icons.star,
                        color: color,
                        size: 32,
                      ),
                      // animationDuration: Duration(milliseconds: 5000),
                      starColor: kYellow,
                      starCount: 5,
                      valueLabelVisibility: false,
                      starSize: 32,
                      starSpacing: 2,
                      starOffColor: Colors.white.withOpacity(0.5),
                      animationDuration: Duration(milliseconds: 500),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.56,
                      child: TextFormField(
                        controller: movieTitle,
                        textInputAction: TextInputAction.next,
                        cursorColor: kYellow,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 2.2)),
                            hintText: 'Enter Movie\'s Name',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        controller: directorName,
                        textInputAction: TextInputAction.next,
                        cursorColor: kYellow,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 2.2)),
                            hintText: 'Enter Director\'s Name',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        maxLines: 2,
                        cursorColor: kYellow,
                        controller: movieDesc,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 2.2)),
                            hintText: 'What was movie about?',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
