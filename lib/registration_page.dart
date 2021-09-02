import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movist_app/login_page.dart';

import 'constants.dart';

class SignUp extends StatefulWidget {
  static String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var dbRef = FirebaseDatabase.instance.reference();

  TextEditingController userName = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController password = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    try {
      final newPerson = await _firebaseAuth.createUserWithEmailAndPassword(
          email: userEmail.text, password: password.text);
      User? newUser = newPerson.user;

      if (newUser != null) {
        final User newUser = await _firebaseAuth.currentUser!;
        final userId = newUser.uid;
        dbRef.child(userId).set({
          "name": userName.text,
          "email": userEmail.text.trim(),
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB43A),
                ),
              );
            });
        Fluttertoast.showToast(
          msg: 'Account Created!',
          textColor: Color(0xFFFFB43A),
          backgroundColor: Color(0xFF20212C).withOpacity(0.4),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Color(0xFFFFB43A),
        backgroundColor: Color(0xFF272833).withOpacity(0.8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: kBackColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign up',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  // width: MediaQuery.of(context).size.width*0.4,
                  child: TextFormField(
                    controller: userName,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: Color(0xFFFFB43A),
                    decoration: InputDecoration(
                      hintText: 'Enter your Name',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontSize: 15),
                      filled: true,
                      fillColor: Color(0xFF272833),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  // width: MediaQuery.of(context).size.width*0.4,
                  child: TextFormField(
                    controller: userEmail,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: Color(0xFFFFB43A),
                    decoration: InputDecoration(
                      hintText: 'Enter your Email Address',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontSize: 15),
                      filled: true,
                      fillColor: Color(0xFF272833),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  // width: MediaQuery.of(context).size.width*0.4,
                  child: TextFormField(
                    controller: password,
                    obscureText: true,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: Color(0xFFFFB43A),
                    decoration: InputDecoration(
                      hintText: 'Enter your Name',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w300,
                          fontSize: 15),
                      filled: true,
                      fillColor: Color(0xFF272833),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 23,
              ),
              Container(
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 55,
                  onPressed: () {
                    registerNewUser(context);
                    Navigator.pushReplacementNamed(context, LoginPage.id);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Color(0xFFFFB43A),
                  child: Text(
                    'Signup',
                    style: TextStyle(color: kBackColor),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Text(
                    'Already Have An Account? ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, LoginPage.id);
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Color(0xFFFFB43A),
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
