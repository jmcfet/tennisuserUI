import 'package:flutter/material.dart';
import 'root_page.dart';
import 'auth.dart';
import 'dart:html';
import 'login_page.dart';
import 'Introduction.dart';


void main() {
  getParams();
  runApp(MyApp());
}
String origin;
void getParams() {
  var uri = Uri.dataFromString(window.location.href);
  Map<String, String> params = uri.queryParameters;
   origin = params['origin'];
   if (origin == null)
     origin = "john";
  var destiny = params['destiny'];
  print(origin);
  print(destiny);
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: origin,
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new AuthASP(),userid: origin,),
    );
  }

}

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth,this.userid}) : super(key: key);
  final AuthASP auth;
  String userid;

  @override
  State<StatefulWidget> createState() => new _RootPageState(auth);
}

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  _RootPageState(this.auth);

  final AuthASP auth;
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
          title: widget.userid,
          auth: widget.auth,
          onSignedIn: () => _updateAuthStatus(AuthStatus.signedIn),

        );
      case AuthStatus.signedIn:
        return new Intro(
          auth: widget.auth,
          //      onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}