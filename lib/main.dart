import 'package:firebase_account/screens/sign_in_screen.dart';
import 'package:firebase_account/screens/task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  Future<bool> _checkLogin() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;

    User? user = auth.currentUser;

    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FireBase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return const TaskListScreen();
              } else if (snapshot.data == false) {
                return const SignInScreen();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
