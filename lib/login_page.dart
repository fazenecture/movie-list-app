import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movist_app/movie_list.dart';
import 'package:movist_app/registration_page.dart';

import 'constants.dart';

class LoginPage extends StatefulWidget {
  static String id = 'login_page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController emailAddress = TextEditingController();
  TextEditingController password = TextEditingController();

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
                'Login',
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
                    controller: emailAddress,
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
                  onPressed: () async {
                    try {
                      final user =
                          await _firebaseAuth.signInWithEmailAndPassword(
                              email: emailAddress.text,
                              password: password.text);
                      if (user != null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFB43A),
                                ),
                              );
                            });
                        Navigator.pushNamedAndRemoveUntil(context, MovieList.id, (route) => false);
                        Fluttertoast.showToast(
                          msg: 'Logged In',
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Color(0xFFFFB43A),
                  child: Text(
                    'Login',
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
                    'Don\'t Have An Account? ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, SignUp.id);
                      // Navigator.pushReplacementNamed(context, SignUp.id);
                      Navigator.pushNamedAndRemoveUntil(context, SignUp.id, (route) => false);
                    },
                    child: Text(
                      'Register',
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
