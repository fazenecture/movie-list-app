import 'package:flutter/material.dart';
import 'package:movist_app/add_movie.dart';
import 'package:movist_app/login_page.dart';
import 'package:movist_app/movie_desc.dart';
import 'package:movist_app/movie_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movist_app/registration_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final _firebaseauth = FirebaseAuth.instance;

Future<User> getCurrentUser() async{
  User currentUser;
  currentUser = await _firebaseauth.currentUser!;
  return currentUser;
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        SignUp.id: (context) => SignUp(),
        LoginPage.id: (context) => LoginPage(),
        AddMovie.id: (context) => AddMovie(),
        MovieList.id: (context) => MovieList(),
        MovieDetails.id: (context) => MovieDetails(mName: '',),
      },
      home: FutureBuilder(
        future: getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return MovieList();
          } else{
            return LoginPage();
          }
        },
      ),
    );
  }
}
