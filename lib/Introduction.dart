import 'package:flutter/material.dart';
import 'Calender/CalenderHome.dart';
import 'auth.dart';
import 'globals.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'matchsGrid.dart';
import 'primary_button.dart';

class Intro extends StatelessWidget {
  Intro({this.auth});

  final AuthASP auth;
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final int month =  DateTime.now().month;
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
                      child: PrimaryButton(
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
                                  builder: (context) => UserMatchsDataGrid(auth: new AuthASP(),month:month)


                              )
                          );
                        },
                      ),

                    ),
                  ],
                ))));
  }
}
