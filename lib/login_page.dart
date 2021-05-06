import 'package:flutter/material.dart';
import 'package:login/playhelp.dart';
import 'primary_button.dart';
import 'auth.dart';
import 'Models/user.dart';
import 'Models/UserResponse.dart';
import 'package:login/globals.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth,this.onSignedIn}) : super(key: key);
  final VoidCallback onSignedIn;
  final String title;
  final AuthASP auth;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  static final formKey = new GlobalKey<FormState>();
  User _user = new User();

  FormType _formType = FormType.login;
  String _authHint = '';

  void initState() {


    super.initState();

  }
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (_formType == FormType.login) {
        UserResponse resp = await widget.auth.signIn(
            _user.userid, _user.password);

        if (resp.error == '200') {
          resp = await widget.auth.getUser(
              _user.userid);
          Globals.user = resp.user;
          widget.onSignedIn();
        } else {
          setState(() {
            _authHint = resp.error;
          });
        }
      } else {
        UserResponse resp = await widget.auth.register(_user);

        if (resp.error == '200') {
          moveToLogin();
        } else {
          if (resp.error == '404 '){
            _showDialog("Must be Club member");
          }
          setState(() {
            _authHint = resp.error;
          });
        }
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = 'userid is id you will use to login;email must be one known to club; ';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }


  List<Widget> usernameAndPassword() {
    return [
      padded(child: new TextFormField(
        key: new Key('UserID'),
 //       keyboardType: TextInputType.emailAddress,
        decoration: new InputDecoration(labelText: 'User ID '),
         autocorrect: false,
   //     initialValue: 'jmcfet',
 //       validator: (val) => validateEmail(val),
        onSaved: (val) => _user.userid = val,
      )),
      _formType == FormType.register? padded(child: new TextFormField(
        key: new Key('Name (John Smith)'),
        decoration: new InputDecoration(labelText: 'Name ' ),
        autocorrect: false,
    //    validator: (val) => validateEmail(val),
        onSaved: (val) => _user.Name = val,
      )):Container(),
      _formType == FormType.register? padded(child: new TextFormField(
        key: new Key('Name (John Smith)'),
        decoration: new InputDecoration(labelText: 'EMail '),
        autocorrect: false,
        validator: (val) => validateEmail(val),
        onSaved: (val) => _user.email = val,
      )):Container(),
      padded(child: new TextFormField(
        key: new Key('password'),
        decoration: new InputDecoration(labelText: 'Password (must be 6 characters)'),
        obscureText: true,
        autocorrect: false,
        validator: (val) => validatepassword(val),
        onSaved: (val) => _user.password = val,
      )),
      _formType == FormType.register? padded(child: new TextFormField(
        key: new Key('confirm password'),
        decoration: new InputDecoration(labelText: 'confirm Password'),
  //      initialValue: '1234567h',
        obscureText: true,
        autocorrect: false,
        validator: (val) => _user.password != val ? 'Password must match' : null,
    //    onSaved: (val) => comparepass(val),
      )):Container()

    ];
  }

  //For Email Verification we using RegEx.
  String validateEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if(!regExp.hasMatch(value)){
      return "Invalid Email";
    }else {
      return null;
    }
  }
  String confirmPassword(value)
  {
    if (_user.password != value)
      return  'Password must match';
    return null;
  }
  String validatepassword(String value) {
    if (value.isEmpty)
      return  'Password must be filled in';
    _user.password = value;
    return null;
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          new PrimaryButton(
            key: new Key('login'),
            text: 'Login',
            height: 44.0,
            onPressed: validateAndSubmit
          ),
          new FlatButton(
            key: new Key('need-account'),
            child: new Text("Need an account? REGISTER"),
            onPressed: moveToRegister
          ),

        ];
      case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('register'),
            text: 'Create an Club account',
            height: 44.0,
            onPressed: validateAndSubmit
          ),
          new TextButton(
            key: new Key('need-login'),
            child: new Text("Have an account? LOGIN"),
            onPressed: moveToLogin
          ),
        ];
    }
    return null;
  }

  Widget hintText(color) {
    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: color),
            textAlign: TextAlign.center)
    );
  }
  void _showDialog(String err) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Landing Register"),
          content: new Text(err),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  PlayHelpVideo()
  {
    Navigator.push(
        context,
        MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
        builder: (context) => PlayVideo()
        )

    );
  }
  @override
  Widget build(BuildContext context) {
    String heading = FormType.register == true ? 'Landings Club member registration' : 'Landings Club Login';
    return MaterialApp(
  //      navigatorKey: widget.auth.alice.getNavigatorKey(),
        debugShowCheckedModeBanner: false,
      home: new Scaffold(

      appBar: new AppBar(
        title:   Text(heading),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.play_circle_filled),
                onPressed: () {
                PlayHelpVideo();
                },
            )],
      ),
      backgroundColor: Colors.grey[300],
      body: new SingleChildScrollView(child: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: [
            new Card(
              child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: usernameAndPassword() + submitWidgets(),
                        )
                    )
                ),
              ])
            ),
            hintText(Colors.blueAccent)
          ]
        )
      )
      )
    )
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}

