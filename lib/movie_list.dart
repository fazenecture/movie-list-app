import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:movist_app/add_movie.dart';
import 'package:movist_app/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movist_app/login_page.dart';
import 'package:movist_app/movie_desc.dart';
import 'package:movist_app/registration_page.dart';
import 'package:image_picker/image_picker.dart';

class MovieList extends StatefulWidget {
  static String id = 'movie_list';

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late User user;
  var dbRef = FirebaseDatabase.instance.reference();
  List<Map<dynamic, dynamic>> movieList = [];
  List mList = [];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _firebaseAuth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'stob',
          onPressed: () {
            Navigator.pushNamed(context, AddMovie.id);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          label: Text('Add Movies'),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: kYellow,
        ),
        backgroundColor: kBackColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Vivek!',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Let\'s relax and watch a movie!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        Divider(
                          color: kSecondColor,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        _firebaseAuth.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginPage.id, (route) => false);
                      },
                      child: Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: dbRef.child('${user.uid}/Movies').once(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // print(snapshot.data.value);
                    if(snapshot.connectionState == ConnectionState.done){

                      if(snapshot.hasData){
                        movieList.clear();
                        mList.clear();
                        var data = snapshot.data.value;
                        // print(data.length);
                        // print(data);
                        Map<dynamic, dynamic> values = data;
                        values.forEach((key, value) {
                          // movieList.add(value);
                          mList.add(value);
                          print(mList);
                        });


                        return GridView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          primary: false,
                          itemCount: mList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: (0.7 / 0.9), crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            var title = mList[index]['Title'];
                            int star = mList[index]['Rating'];
                            var imgUrl = mList[index]['ImageUrl'];
                            double vStar = star.toDouble();

                            print(title);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetails(
                                                  mName: title)));
                                },
                                onLongPress: (){
                                  setState(() {
                                    dbRef.child('${user.uid}/Movies/$title').remove();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kSecondColor,
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage('$imgUrl'),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withOpacity(0.2),
                                                  Colors.black.withOpacity(0.9)
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter)),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$title',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.start,
                                              ),
                                              RatingStars(
                                                value: vStar,
                                                starBuilder: (index, color) => Icon(
                                                  Icons.star,
                                                  color: color,
                                                  size: 16,
                                                ),
                                                // animationDuration: Duration(milliseconds: 5000),
                                                starColor: kYellow,
                                                starCount: 5,
                                                valueLabelVisibility: false,
                                                starSize: 16,
                                                starOffColor: Colors.white.withOpacity(0.6),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }else{
                        return Center(
                            child: Text(
                              'ADD SOME MOVIES TO\nGET STARTED!!',
                              style: TextStyle(
                                fontSize: 18,
                                color: kYellow.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            )
                        );
                      }
                    }else{
                     return Center(
                       child: CircularProgressIndicator(
                         color: kYellow,
                       ),
                     );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
