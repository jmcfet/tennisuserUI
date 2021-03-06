import 'package:flutter/material.dart';
import 'Introduction.dart';
import 'auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import "package:login/Calender/CalenderHome.dart";


class RootPage extends StatefulWidget {
  RootPage({required Key key, required this.auth,required this.userid}) : super(key: key);
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
      authStatus =  AuthStatus.notSignedIn;
    });

  }

  void _updateAuthStatus(AuthStatus status)  {
//set correct state for build
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context)  {
    switch (authStatus) {
      case AuthStatus.notSignedIn:

       return new LoginPage(
         key:widget.key,
          title: widget.userid,
          auth: widget.auth,
          onSignedIn: () => _updateAuthStatus(AuthStatus.signedIn),

        );
      case AuthStatus.signedIn:

        return new Intro(
            auth: widget.auth,
            key: widget.key,
      //      onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}