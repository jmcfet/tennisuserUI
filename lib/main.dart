import 'package:flutter/material.dart';
import 'root_page.dart';
import 'auth.dart';
//import 'dart:html';
import 'login_page.dart';
import 'Introduction.dart';


void main() {

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'origin',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(key:key),
    );
  }

}

class RootPage extends StatefulWidget {
  RootPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  _RootPageState();

  final AuthASP auth = new AuthASP();
  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();

    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void _updateAuthStatus(AuthStatus status) {
//set correct state for build
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          title: 'title',
          key:widget.key,
          auth: new AuthASP(),
          onSignedIn: () => _updateAuthStatus(AuthStatus.signedIn),

        );
      case AuthStatus.signedIn:
        return new Intro(
          auth: new AuthASP(),
          key:widget.key,
          //      onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}