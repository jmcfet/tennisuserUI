import 'package:flutter/material.dart';
import 'Introduction.dart';
import 'auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import "package:login/Calender/CalenderHome.dart";


class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final AuthASP auth;

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

    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context)  {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          title: 'Landings Login',
          auth: widget.auth,
          onSignedIn: () => _updateAuthStatus(AuthStatus.signedIn),
        //  alice:widget.alice
        );
      case AuthStatus.signedIn:

        return new Intro(
            auth: widget.auth,
      //      onSignOut: () => _updateAuthStatus(AuthStatus.notSignedIn)
        );
    }
  }
}