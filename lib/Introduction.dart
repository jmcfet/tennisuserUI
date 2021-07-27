import 'package:flutter/material.dart';
import 'Calender/CalenderHome.dart';
import 'Matchsgrid2.dart';
import 'auth.dart';
import 'globals.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'matchsGrid.dart';
import 'primary_button.dart';
class Intro extends StatefulWidget {
  Intro({Key key,  this.auth}) : super(key: key);

  final AuthASP auth;

  @override
  _IntroPageState createState() => new _IntroPageState();
}


class _IntroPageState extends State<Intro> {


  static final formKey = new GlobalKey<FormState>();
  bool bFroozen;
  void initState() {


    super.initState();
    getDBState();
  }
  Future <void> getDBState( ) async {

       bool btemp =     await widget.auth.isDBFrozen();
       btemp = false;
      setState(() => bFroozen = btemp);
      return;
  }
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
  //  final int month =  DateTime.now().month;
    final int month = 7;
    return MaterialApp(

           debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text('Landings MWF Tennis'),
            ),
            body: new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(   //Use of SizedBox
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: !bFroozen ? PrimaryButton(
                        text: 'schedule your matchs for  ${  _monthNames[month]}',
                        height: 44.0,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => CalenderHome(auth: new AuthASP(),viewOnlyMode:false,month: month+1)


                              )
                          );
                        },
                      ) : Container(),
                    ),
                    SizedBox(   //Use of SizedBox
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:
                      PrimaryButton(
                          key: new Key('login'),
                          text: 'view your schedule for  ${  _monthNames[month-1]}',
                          height: 44.0,
                        onPressed: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => CalenderHome(auth: new AuthASP(),viewOnlyMode:true,month:month)


                              )
                          );
                        },
                      ),

                    ),

                    SizedBox(   //Use of SizedBox
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:
                      PrimaryButton(
                        key: new Key('login'),
                        text: 'view GRID schedule for  ${  _monthNames[month-1]}',
                        height: 44.0,
                        onPressed: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => UserMatchsDataGrid2(auth: new AuthASP(),month:month)


                              )
                          );
                        },
                      ),

                    ),

                  ],
                ))));
  }
}
