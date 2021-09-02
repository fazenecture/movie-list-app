import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'constants.dart';
import 'package:path/path.dart';

import 'movie_list.dart';

class MovieDetails extends StatefulWidget {
  static String id = 'movie_details';
  final String mName;

  MovieDetails({required this.mName});

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late User user;
  var dbRef = FirebaseDatabase.instance.reference();
  TextEditingController movieTitle = TextEditingController();
  TextEditingController directorName = TextEditingController();
  TextEditingController movieDesc = TextEditingController();
  UploadTask? task;
  File? file;
  final ImagePicker _picker = ImagePicker();
  var imageUrl;
  late bool isClicked = false;
  List descList = [];
  var desc;
  var title;
  var director;
  late int star;
  var img;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _firebaseAuth.currentUser!;
  }

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

  late double vStar = 0;

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    var userid = user.uid;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, MovieList.id);
        return new Future(() => false);
      },
      child: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'stob',
            onPressed: () {
              setState(() {
                if (isClicked == false) {
                  isClicked = true;
                  // eText = 'Submit';
                } else {
                  isClicked = false;
                  try {
                    print(desc);
                    dbRef.child('${user.uid}/Movies/${widget.mName}').update({
                      "Title": title,
                      "Director": director,
                      "Desc": desc,
                      "Rating": vStar,
                      "ImageUrl": imageUrl == null ? img : imageUrl,
                    });
                    // Navigator.pushReplacementNamed(context, MovieList.id);
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString(),
                      textColor: Color(0xFFFFB43A),
                      backgroundColor: Color(0xFF272833).withOpacity(0.8),
                    );
                  }
                  // eText = '';
                }
              });
            },
            label: isClicked == true
                ? Text('Submit')
                : Text(
                    '',
                    style: TextStyle(fontSize: 0),
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            backgroundColor: kYellow,
          ),
          resizeToAvoidBottomInset: true,
          backgroundColor: kBackColor,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                FutureBuilder(
                  future: dbRef.child('${user.uid}/Movies/${widget.mName}').once(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      descList.clear();
                      var data = snapshot.data.value;
                      print(data);
                      Map<dynamic, dynamic> values = data;
                      values.forEach((key, value) {
                        // movieList.add(value);
                        descList.add(value);
                        // print(descList);
                      });

                      desc = data['Desc'];
                      title = data['Title'];
                      director = data['Director'];
                      star = data['Rating'];
                      img = data['ImageUrl'];

                      vStar = star.toDouble();

                      return isClicked == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: uploadImageToFirebase,
                                  child: Stack(
                                    children: [
                                      file != null
                                          ? Container(
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
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
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                                                image: DecorationImage(
                                                  image: NetworkImage(img),
                                                  // image:
                                                  //     imageUrl != null ? NetworkImage('imageUrl') : NetworkImage('https://picsum.photos/250?image=9'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                      Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
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
                                  padding:
                                      EdgeInsets.only(left: 30, right: 30, top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RatingStars(
                                        value: vStar,
                                        onValueChanged: (v) {
                                          setState(() {
                                            vStar = v;
                                            dbRef
                                                .child(
                                                    '${user.uid}/Movies/${widget.mName}')
                                                .update({
                                              "Rating": vStar,
                                            });
                                          });
                                          print(vStar);
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
                                        animationDuration:
                                            Duration(milliseconds: 500),
                                      ),
                                      SizedBox(
                                        height: 13,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.56,
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      // Container(
                                      //   width:
                                      //       MediaQuery.of(context).size.width * 0.56,
                                      //   child: TextFormField(
                                      //     // controller: movieTitle,
                                      //     textInputAction: TextInputAction.next,
                                      //     cursorColor: kYellow,
                                      //     initialValue: title,
                                      //     onChanged: (value) {
                                      //       setState(() {
                                      //         title = value;
                                      //         dbRef.child('${user.uid}/Movies/$title').update({
                                      //           "Title": title,
                                      //         });
                                      //       });
                                      //     },
                                      //     onFieldSubmitted: (value) {
                                      //       setState(() {
                                      //         title = value;
                                      //         dbRef.child('${user.uid}/Movies/$title').update({
                                      //           "Title": title,
                                      //           "Director": director,
                                      //           "Desc": desc,
                                      //           "Rating": vStar,
                                      //           "ImageUrl": imageUrl == null ? img : imageUrl,
                                      //         });
                                      //
                                      //         dbRef.child('${user.uid}/Movies/${widget.mName}').remove();
                                      //       });
                                      //     },
                                      //     style: TextStyle(
                                      //         color: Colors.white,
                                      //         fontSize: 13,
                                      //         fontWeight: FontWeight.w500),
                                      //     decoration: InputDecoration(
                                      //         contentPadding: EdgeInsets.only(
                                      //             bottom: -7, top: 16),
                                      //         border: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white)),
                                      //         enabledBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white
                                      //                     .withOpacity(0.4),
                                      //                 width: 1.5)),
                                      //         focusedBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white
                                      //                     .withOpacity(0.6),
                                      //                 width: 2.2)),
                                      //         hintText: 'Enter Movie\'s Name',
                                      //         hintStyle: TextStyle(
                                      //             color:
                                      //                 Colors.white.withOpacity(0.8),
                                      //             fontSize: 13,
                                      //             fontWeight: FontWeight.w400)),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width * 0.6,
                                        child: TextFormField(
                                          // controller: directorName,
                                          textInputAction: TextInputAction.next,
                                          cursorColor: kYellow,
                                          initialValue: director,
                                          onChanged: (value) {
                                            setState(() {
                                              director = value;
                                              dbRef
                                                  .child(
                                                      '${user.uid}/Movies/${widget.mName}')
                                                  .update({
                                                "Director": director,
                                              });
                                              // isClicked = true;
                                            });
                                          },
                                          onFieldSubmitted: (value) {
                                            setState(() {
                                              director = value;
                                              dbRef
                                                  .child(
                                                      '${user.uid}/Movies/${widget.mName}')
                                                  .update({
                                                "Director": director,
                                              });
                                              // isClicked = true;
                                            });
                                            print(director);
                                          },
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: -7, top: 16),
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                      width: 1.5)),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      width: 2.2)),
                                              hintText: 'Enter Director\'s Name',
                                              hintStyle: TextStyle(
                                                  color:
                                                      Colors.white.withOpacity(0.8),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width * 0.8,
                                        child: TextFormField(
                                          maxLines: 2,
                                          cursorColor: kYellow,
                                          // controller: movieDesc,
                                          onChanged: (value) {
                                            setState(() {
                                              desc = value;
                                              dbRef
                                                  .child(
                                                      '${user.uid}/Movies/${widget.mName}')
                                                  .update({
                                                "Desc": desc,
                                              });
                                            });
                                          },
                                          onFieldSubmitted: (value) {
                                            setState(() {
                                              desc = value;
                                              dbRef
                                                  .child(
                                                      '${user.uid}/Movies/${widget.mName}')
                                                  .update({
                                                "Desc": desc,
                                              });
                                            });
                                          },
                                          initialValue: desc,
                                          textInputAction: TextInputAction.done,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: -7, top: 16),
                                              border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                      width: 1.5)),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      width: 2.2)),
                                              hintText: 'What was movie about?',
                                              hintStyle: TextStyle(
                                                  color:
                                                      Colors.white.withOpacity(0.8),
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
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    img != null
                                        ? Container(
                                            width: double.infinity,
                                            height:
                                                MediaQuery.of(context).size.height *
                                                    0.5,
                                            decoration: BoxDecoration(
                                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                                              image: DecorationImage(
                                                image: NetworkImage(img),
                                                // image:
                                                //     imageUrl != null ? NetworkImage('imageUrl') : NetworkImage('https://picsum.photos/250?image=9'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: double.infinity,
                                            height:
                                                MediaQuery.of(context).size.height *
                                                    0.5,
                                            child: Center(
                                              child: Icon(
                                                Icons.error,
                                                color: kSecondColor,
                                                size: 140,
                                              ),
                                            ),
                                          ),
                                    Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height * 0.5,
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
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 30, right: 30, top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RatingStars(
                                        value: vStar,
                                        // onValueChanged: (v) {
                                        //   setState(() {
                                        //     sValue = v;
                                        //   });
                                        //   print(sValue);
                                        // },
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
                                        animationDuration:
                                            Duration(milliseconds: 500),
                                      ),
                                      SizedBox(
                                        height: 13,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.56,
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      // Container(
                                      //   width: MediaQuery.of(context).size.width * 0.56,
                                      //   child: TextFormField(
                                      //     controller: movieTitle,
                                      //     textInputAction: TextInputAction.next,
                                      //     cursorColor: kYellow,
                                      //     style: TextStyle(
                                      //         color: Colors.white,
                                      //         fontSize: 13,
                                      //         fontWeight: FontWeight.w500),
                                      //     decoration: InputDecoration(
                                      //         border: UnderlineInputBorder(
                                      //             borderSide: BorderSide(color: Colors.white)),
                                      //         enabledBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.4),
                                      //                 width: 1.5)),
                                      //         focusedBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.6),
                                      //                 width: 2.2)),
                                      //         hintText: 'Enter Movie\'s Name',
                                      //         hintStyle: TextStyle(
                                      //             color: Colors.white.withOpacity(0.8),
                                      //             fontSize: 13,
                                      //             fontWeight: FontWeight.w400)),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width * 0.6,
                                        child: Text(
                                          director,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      // Container(
                                      //   width: MediaQuery.of(context).size.width * 0.6,
                                      //   child: TextFormField(
                                      //     controller: directorName,
                                      //     textInputAction: TextInputAction.next,
                                      //     cursorColor: kYellow,
                                      //     style: TextStyle(
                                      //         color: Colors.white,
                                      //         fontSize: 13,
                                      //         fontWeight: FontWeight.w500),
                                      //     decoration: InputDecoration(
                                      //         border: UnderlineInputBorder(
                                      //             borderSide: BorderSide(color: Colors.white)),
                                      //         enabledBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.4),
                                      //                 width: 1.5)),
                                      //         focusedBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.6),
                                      //                 width: 2.2)),
                                      //         hintText: 'Enter Director\'s Name',
                                      //         hintStyle: TextStyle(
                                      //             color: Colors.white.withOpacity(0.8),
                                      //             fontSize: 13,
                                      //             fontWeight: FontWeight.w400)),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width * 0.8,
                                        child: Text(
                                          desc,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      // Container(
                                      //   width: MediaQuery.of(context).size.width * 0.8,
                                      //   child: TextFormField(
                                      //     maxLines: 2,
                                      //     cursorColor: kYellow,
                                      //     controller: movieDesc,
                                      //     textInputAction: TextInputAction.done,
                                      //     style: TextStyle(
                                      //         color: Colors.white,
                                      //         fontSize: 13,
                                      //         fontWeight: FontWeight.w500),
                                      //     decoration: InputDecoration(
                                      //         border: UnderlineInputBorder(
                                      //             borderSide: BorderSide(color: Colors.white)),
                                      //         enabledBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.4),
                                      //                 width: 1.5)),
                                      //         focusedBorder: UnderlineInputBorder(
                                      //             borderSide: BorderSide(
                                      //                 color: Colors.white.withOpacity(0.6),
                                      //                 width: 2.2)),
                                      //         hintText: 'What was movie about?',
                                      //         hintStyle: TextStyle(
                                      //             color: Colors.white.withOpacity(0.8),
                                      //             fontSize: 13,
                                      //             fontWeight: FontWeight.w400)),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 70,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: kYellow,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
