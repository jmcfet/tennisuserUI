import 'package:flutter/material.dart';
import 'Calender/CalenderHome.dart';
import 'Matchsgrid2.dart';
import 'Models/MatchDTO.dart';
import 'auth.dart';
import 'globals.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'primary_button.dart';
import 'Models/user.dart';
import 'package:login/Models/UsersResponse.dart';
import "Models/AllBookedDatesResp.dart";
import 'Calender/Calender.dart';
class Intro extends StatefulWidget {
  Intro({required Key? key,  required this.auth}) : super(key: key);

  final AuthASP auth;

  @override
  _IntroPageState createState() => new _IntroPageState();
}


class _IntroPageState extends State<Intro> {


  static final formKey = new GlobalKey<FormState>();
  bool bFroozen = false;
  Map<String,double> columnswidths = Map();
 // List<MatchDTO>? matchs ;
  List<User> allusers = [];
  List<MatchDTO>? matchs ;
  List<String> columns = [];
  bool bLoggedIn = true;
  late List<Calendar> _daysinMonth;
  List<PlayerData> playersinfo = [];
  List<PlayerData> allPlayers = [];
  void initState() {


    super.initState();
    getDBState();
  }
  Future <void> getDBState( ) async {

       bool btemp =     await widget.auth.isDBFrozen();
       setState(() => bFroozen = true);    //chhange
      return;
  }
  final List<String> _monthNames = ['fillsonot0based','January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December','January'];

  @override
  Widget build(BuildContext context) {
  //  final int month =  DateTime.now().month;
    final int nextMonth = 4;     //0 based
 //   final int currentMonth = nextMonth == 0 ? 11:nextMonth;
    final int currentMonth = 3;
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

                        text: 'schedule your matchs for  ${  _monthNames[nextMonth]}',
                        height: 44.0,
                        key: widget.key,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => CalenderHome(auth: new AuthASP(),viewOnlyMode:false,month: nextMonth)


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
                          text: 'view your schedule for  ${  _monthNames[currentMonth-1]}',
                          height: 44.0,
                        onPressed: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => CalenderHome(auth: new AuthASP(),viewOnlyMode:true,month:currentMonth-1)


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
                        text: 'view your schedule for  ${  _monthNames[currentMonth]}',
                        height: 44.0,
                        onPressed: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => CalenderHome(auth: new AuthASP(),viewOnlyMode:true,month:currentMonth)


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
                        text: 'view GRID schedule for  ${  _monthNames[currentMonth]}',
                        height: 44.0,
                        onPressed: () async {

                          getUsersandInitGrid(currentMonth).whenComplete(() =>
                          Navigator.push(
                              context,
                              MaterialPageRoute(  // transitions to the new route using a platform-specific animation.
                                  builder: (context) => UserMatchsDataGrid2(playersinfoin: playersinfo, allPlayersin: allPlayers, monthin: currentMonth, columnsin: columns,columnwidthsin: columnswidths,)
                              )
                          ));
                        },
                      ),

                    ),

                  ],
                )
            )
        )
    );
  }
  Future <void> getUsersandInitGrid( int currentmonth) async {
    DateTime _currentDateTime = DateTime(DateTime.now().year, currentmonth);
    UsersResponse resp =    await widget.auth.getUsers();
    allusers = resp.users;
    var resp1 = await widget.auth.getAllMatchs();
    AllBookedDatesResponse bookingsresp = await widget.auth.getMonthStatus(currentmonth.toString());
    Map<String ,List<int>> subs = new Map<String ,List<int>>();
    matchs = resp1.matches!.where((element) => element.month == currentmonth).toList();

    //    _tennisDataGridSource.matchs = matchs;

    MatchDTO? last = null;
    List<String> playersinMonth= [];
    int columnNum = 0;
    columns.add( 'Name');
    columnswidths['Name'] = 150;
    if (bLoggedIn) {
      columns.add('EMail');
      columnswidths['EMail'] = 200;
      columns.add('Phone');
      columnswidths['Phone'] = 150;
    }
//use the first bookings for month to get the M-W-F for grid headings
    int day = -1;
    List<String> statusdays = bookingsresp.datesandstatus[0].status.split(',');
    _daysinMonth = CustomCalendar().getJustMonthCalendar(_currentDateTime.month, _currentDateTime.year, statusdays, startWeekDay: StartWeekDay.monday);
    for(int day =0;day < _daysinMonth.length;day++)
    {
      if (_daysinMonth[day].date!.month == currentmonth) {
        if (_daysinMonth[day].date!.weekday == 1 ||
            _daysinMonth[day].date!.weekday == 3 ||
            _daysinMonth[day].date!.weekday == 5) {
          if (!columns.contains(
              _daysinMonth[day].date!.day.toString())) {
            columns.add(
                _daysinMonth[day].date!.day.toString());
            columnswidths[_daysinMonth[day].date!.day.toString()] = 50;
          }
        }
      }
    }
// loop thru every player who registered for month and their playing status (available,sub, etc) this way we
    //pickup the people who were subs and the ones who were available but were not booked
    bookingsresp.datesandstatus.forEach((booking) {


      PlayerData playerinfo = new PlayerData();
      playerinfo.matches =  List<int>.filled(32, 0, growable: false);
      bool bActivePlayer = false;
      if (booking.user!.phonenum == null)
        booking.user!.phonenum = '1111111111';
      playerinfo.name = booking.user.Name!;
      playerinfo.email = booking.user.email!;
      playerinfo.phonenum = booking.user.phonenum!;
      allPlayers.add(playerinfo);
      statusdays = booking.status.split(',');
      //create a list of days in month and the players status for that day
      _daysinMonth = CustomCalendar().getJustMonthCalendar(_currentDateTime.month, _currentDateTime.year, statusdays, startWeekDay: StartWeekDay.monday);
      //loop thru all the M-W-F for month states
      int col = 0;

      for(int day =0;day < _daysinMonth.length;day++)
      {

        // if a M-W-F
        if (_daysinMonth[day].date!.weekday == 1 ||
            _daysinMonth[day].date!.weekday == 3 ||
            _daysinMonth[day].date!.weekday == 5) {
          if (_daysinMonth[day].state == 1) {
            bActivePlayer = true;
            playerinfo.matches[col] = 99;    //a sub
          }
          if (_daysinMonth[day].state == 0) {
            findMatch(_daysinMonth[day].date!.day,playerinfo,col);
            bActivePlayer = true;
          }

        }

        //  }
        col++;
      }

      if (bActivePlayer)
        playersinfo.add(playerinfo);
    });
  }

  findMatch(int day,PlayerData playerinfo,int columnNum){

    List<MatchDTO> matchsforday = matchs!.where((element) =>
    element.day == day).toList();
    int iNumMatch = 0;
    bool bFound = false;
    //we are processing member by member . look thru the matchs for this day and see if member is
    //in the match and if they are the captain
    matchsforday.forEach((matchforday) {
      iNumMatch++;
      for (int ii = 0; ii < 4; ii++) {
        User user = allusers.where((u) => u.email == matchforday.players[ii] ).single;
        if (user.Name == playerinfo.name) {
          bFound = true;
          playerinfo.matches[columnNum] = iNumMatch;
          if (playerinfo.name == matchforday.Captain) {
            playerinfo.CaptainthatDay[columnNum] = 1;
          }

        }
      }
      if (!bFound)  //player was left out as not enough players
        playerinfo.matches[columnNum] = 88;
    });


  }
}
