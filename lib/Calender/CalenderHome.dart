
import 'package:flutter/services.dart';
import 'package:login/Calender/Calender.dart';
import 'package:flutter/material.dart';
import 'package:login/Models/MatchDTO.dart';
import 'package:login/Models/user.dart';
import 'package:login/auth.dart';
import 'package:login/globals.dart';
import "package:login/Models/MatchsResponse.dart";
import 'dart:collection';
import 'package:collection/collection.dart';
//import 'package:mycalender/SERVICE/fileops.dart';
import 'dart:convert';
import "package:login/Models/UserResponse.dart";
import "package:login/Models/UsersResponse.dart";
import "package:login/Models/BookedDatesResponse.dart";
import 'package:awesome_dialog/awesome_dialog.dart';
enum CalendarViews{ dates, months, year }

class CalenderHome extends StatefulWidget {
  final AuthASP auth;
  final bool viewOnlyMode ;
  final int month;
  CalenderHome({this.auth,this.viewOnlyMode,this.month});
  @override
  _MyAppState createState() => _MyAppState(auth,viewOnlyMode,month);
}

class _MyAppState extends State<CalenderHome> {
  _MyAppState(this.auth,this.viewOnlyMode,this.month);
  final AuthASP auth;
  final bool viewOnlyMode ;
  final int month;
  DateTime _currentDateTime;
  DateTime _selectedDateTime;
  List<Calendar> _sequentialDates;
  int midYear;
  CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  List<int> States = List();
  List<MatchDTO> matches = [];
  String existingBookings;
  List<String> statusdays = [];
  List<User> allusers = [];
//  static FileService fileservice = new FileService();
  @override
  void initState()  {
    super.initState();
    final date = DateTime.now();
    _currentDateTime = DateTime(date.year, month);
    _selectedDateTime = DateTime(date.year, month, date.day);
//    getDBState();
    if (viewOnlyMode == true) {
      getuserinfo(month);
      getallUsers();
    }
    else
      {
        getBookDates(month);
      }



  }

  @override
  void dispose() {
    super.dispose();
  }
  Future <bool> getDBState( ) async {
 //   viewOnlyMode =   await auth.isDBFrozen();
    return true;

  }
  Future <String> getuserinfo(int month ) async {
    MatchsResponse resp =   await auth.getMatchsForMonth(month, Globals.user.email);
    matches = resp.matches;
 //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      setState(() => _getCalendar());
 //   });
    return 'done';
  }
  //get the status of each bookable day in the month. e,g june 5 is unavailable
  Future <String> getBookDates(int month ) async {
    BookedDatesResponse resp =   await auth.GetMonthStatusforUser(month.toString(), Globals.user.email);
    if (resp.status != null) {
      int numDays = int.parse(resp.status.status[0]);
      statusdays = resp.status.status.split(',');
    }
    setState(() => _getCalendar());
    return resp.status.status;
  }
  Future <void> getallUsers( ) async {
    UsersResponse resp =    await auth.getUsers();
    allusers = resp.users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (_currentView == CalendarViews.dates) ? _datesView()
                : (_currentView == CalendarViews.months) ? _showMonthsList() : _yearsView(midYear ?? _currentDateTime.year)
        ),

      ),
    );
  }

  // dates view
  Widget _datesView(){
    String title = Globals.user.Name + ' Matches for '  + _monthNames[_currentDateTime.month-1] + ' ' + _currentDateTime.year.toString();
    if (!viewOnlyMode)
     title = Globals.user.Name + ' schedule matchs for  '  + _monthNames[_currentDateTime.month-1] + ' ' + _currentDateTime.year.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // header
        Row(
          children: <Widget>[
            // prev month button
            _toggleBtn(false),
            // month and year
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentView = CalendarViews.months),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            _SaveBtn(context),
            // next month button
            _toggleBtn(true),
          ],
        ),
   //     SizedBox(height: 20,),
        Divider(color: Colors.white,),
        SizedBox(height: 20,),
        Flexible(child: _calendarBody()),
        SizedBox(height: 20,),
        viewOnlyMode == false ? LegendScheduler() : LegendShowSchedule()

      ],
    );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    if (viewOnlyMode == false)
      return Container();
    return InkWell(
      onTap: () async{

          if (viewOnlyMode){
            (next) ? _getNextMonth() : _getPrevMonth();

          }
          MatchsResponse resp = await auth.getMatchsForMonth(_currentDateTime.month, Globals.user.email);
          matches = resp.matches;
          setState(() {});


      },
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: Offset(3, 3),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black.withOpacity(0.1)],
              stops: [0.5, 1],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            )
        ),
        child: Icon((next) ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: Colors.white,),
      ),
    );
  }
  Widget _SaveBtn(context) {
    if (viewOnlyMode == true)
      return Container();
    return InkWell(

      onTap:  () async{
          States.clear();
           int count = 0;
           States.add(0);
           for( int i = 0;  i < _sequentialDates.length;i++){
             if (_sequentialDates[i].thisMonth)
               {
                 States.add( _sequentialDates[i].state);
                 count++;
               }


           }
           States[0] = count;

           UserResponse resp = await auth.SetBookedDatesforuser(Globals.user.email,_currentDateTime.month,States);
           if (resp.error == '200')
             {
               AwesomeDialog(
                   context: context,
                   animType: AnimType.LEFTSLIDE,
                   headerAnimationLoop: false,
                   dialogType: DialogType.INFO,
                   title: 'changes saved',
                   autoHide: Duration(seconds: 2),
               )
                 ..show();
               /*
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: const Text('Saved'),
                 duration: const Duration(seconds: 1),
                 action: SnackBarAction(
                   label: 'ACTION',
                   onPressed: () { },
                 ),
               ));

                */
             }
      },
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: Offset(3, 3),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black.withOpacity(0.1)],
              stops: [0.5, 1],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            )
        ),
        child: Icon( Icons.save, color: Colors.white,),
      ),
    );
  }
  // calendar
  Widget _calendarBody() {
    if(_sequentialDates == null) return Container();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _sequentialDates.length + 7,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 60,
        crossAxisCount: 7,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index){
        if(index < 7) return _weekDayTitle(index);
        Calendar date1 =  _sequentialDates[index - 7];
        if (date1.thisMonth) {
          if (!viewOnlyMode){
              if (_sequentialDates[index - 7].thisMonth) {
                if (_sequentialDates[index - 7].date.weekday == 1 ||
                   _sequentialDates[index - 7].date.weekday == 3 ||
                  _sequentialDates[index - 7].date.weekday == 5
              )
               return _selector(_sequentialDates[index - 7],false);
           }
          }
          else {
            MatchDTO m = matches.firstWhereOrNull((element) =>
            element.day == date1.date.day);
            if (m == null)
              return _calendarDates(_sequentialDates[index - 7]);
            bool bisCaptain = false;
            if (m.Captain == Globals.user.Name)
              bisCaptain = true;
            return _selector(_sequentialDates[index - 7],bisCaptain);
          }
        }
        return _calendarDates(_sequentialDates[index - 7]);
      }

    );
  }
  Widget LegendShowSchedule() {
    return Container(
        color: Colors.black,
        height: 40,
        child: Column(
          children: [
            Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle
                    ),

                  ),
                  Text("  Red indicates you are Captain that day  ",
                    style: TextStyle(
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                    ),
                  ),
                  Text("  Green that you have a match",
                    style: TextStyle(
                        color: Colors.white),
                    textAlign: TextAlign.center,),
                ]

            )
          ],
        )

    );

  }
  Widget LegendScheduler() {
    return Container(
        color: Colors.black,
        height: 40,
        child: Column(
          children: [
            Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                    ),

                  ),
                  Text(" green indicates you are available  (press to change status) ",
                    style: TextStyle(
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),

                ]

            )
          ],
        )

    );

  }
  // calendar header
  Widget _weekDayTitle(int index){
    return Text(_weekDays[index], style: TextStyle(color: Colors.yellow, fontSize: 12),);
  }

  // calendar element
  Widget _calendarDates(Calendar calendarDate){
    return InkWell(
      onTap: (){
        if(_selectedDateTime != calendarDate.date){
          if(calendarDate.nextMonth){
            _getNextMonth();
          }
          else if(calendarDate.prevMonth){
            _getPrevMonth();
          }
          setState(() => _selectedDateTime = calendarDate.date);
        }
      },
      child: Center(
          child: Text(
            '${calendarDate.date.day}',
            style: TextStyle(
              color: (calendarDate.thisMonth)
                  ? (calendarDate.date.weekday == DateTime.sunday) ? Colors.yellow : Colors.white
                  : (calendarDate.date.weekday == DateTime.sunday) ? Colors.yellow.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            ),
          )
      ),
    );
  }

  // date selector
  Widget _selector(Calendar calendarDate,bool bCaptain) {
    var currentColor = Colors.green.withOpacity(0.9);
  //  int state =_sequentialDates[calendarDate.date.day].state;

 //   if(States[calendarDate.date.day]  == null)
 //     States[calendarDate.date.day] = 0;
    switch (calendarDate.state){
      case  1:
        currentColor = Colors.yellow;
        break;
      case  2:
        currentColor = Colors.grey;
        break;
      default:
        currentColor = bCaptain == true?  Colors.red.withOpacity(0.9):
        Colors.green.withOpacity(0.9);

    }

    return Center(


      child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(25),
          ),
          child: RaisedButton(
            color: currentColor,
            child: Text( '${calendarDate.date.day}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            onPressed: ()  {
              selectedDate = calendarDate.date.day;
              if (!viewOnlyMode) {
         //       showChoices();
                _showSingleChoiceDialog(context,calendarDate.state);
                return;
              }
             //    .then((value) async{
              //      if (_sequentialDates[selectedDate].state == 8){
              MatchDTO m = matches.firstWhereOrNull((element) => element.day == selectedDate);

              showPlayers(m);

            }
   //                 });
         //   },
          )
      ),
    );
  }
  final List<String> states = ['available','unavailable', 'sub'     ];
  String currentChoice;
  int selectedDate;
  _showSingleChoiceDialog(BuildContext context,int state) => showDialog(
      context: context,
      builder: (context) {
        //   var _singleNotifier = Provider.of<SingleNotifier>(context);
        return AlertDialog(
            title: Text("Select one "),
            content: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: states
                      .map((e) => RadioListTile(
                      title: Text(e),
                      value: e,
                      groupValue: currentChoice,
                      selected: currentChoice == e,
                      onChanged: (value) {
                    //    if (value != currentChoice) {
                         setState( () {
                           var test = selectedDate;
                           Calendar selectedday = _sequentialDates.where((element) => element.date.month == _currentDateTime.month &&
                               element.date.day == selectedDate).singleOrNull;
                           switch (value) {
                             case 'available':
                                selectedday.state = 0;
                                break;
                              case 'sub':
                                selectedday.state = 1;
                                break;
                              case 'unavailable':
                                selectedday.state = 2;
                                break;
                              case 'match':
                                selectedday.state = 8;
                                break;
                              default:
                                selectedday.state = 0;
                            }
                          }
                          );

                          Navigator.of(context).pop();
                       // }
                      }
                  ))
                      .toList(),
                ),
              ),
            ));
      });
  showPlayers(MatchDTO m){
     AwesomeDialog dialog;
     dialog = AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      keyboardAware: true,
      width: 500,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              'match',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 10,
            ),
            Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child: Row(
                  children:
                    getPlayerinfoforMatch(m.players[0])
                  ,
                )


            ),
            SizedBox(
              height: 10,
            ),
            Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child:   Row(
                  children: getPlayerinfoforMatch(m.players[1])
                )
            ),
            SizedBox(
              height: 10,
            ),
            Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child:   Row(
                  children:
                    getPlayerinfoforMatch(m.players[2])
                  ,
                )
            ),
            SizedBox(
              height: 10,
            ),
            Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child:   Row(
                  children:
                  getPlayerinfoforMatch(m.players[3])
                  ,
                )
            ),
            SizedBox(
              height: 10,
            ),
            AnimatedButton(
                text: 'Close',
                pressEvent: () {
                  dialog.dissmiss();
                })
          ],
        ),
      ),
    )..show();
  }

  showChoices(){
    AwesomeDialog dialog;
    final List<String> states = ['available','unavailable', 'sub'     ];
    dialog = AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      keyboardAware: true,
      width: 500,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:  SingleChildScrollView(
            child: Container(
            width: double.infinity,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: states
                      .map((e) => RadioListTile(
                            title: Text(e),
                            value: e,
                            groupValue: currentChoice,
                            selected: currentChoice == e,
                            onChanged: (value) {

                              setState( () {
                                var test = selectedDate;
                                Calendar selectedday = _sequentialDates.where((element) => element.date.month == _currentDateTime.month &&
                                    element.date.day == selectedDate).singleOrNull;
                                switch (value) {
                                  case 'available':
                                    selectedday.state = 0;
                                    break;
                                  case 'sub':
                                    selectedday.state = 1;
                                    break;
                                  case 'unavailable':
                                    selectedday.state = 2;
                                    break;
                                  case 'match':
                                    selectedday.state = 8;
                                    break;
                                  default:
                                    selectedday.state = 0;
                                }
                              }
                              );

                            }
                        )
                      ).toList(),
                    )
             )
        )

      ))..show();
  }
  // get next month calendar
  void _getNextMonth() {
    if(_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year+1, 1);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month+1);
    }

    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth(){
    if(_currentDateTime.month == 1){
      _currentDateTime = DateTime(_currentDateTime.year-1, 12);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime.year, _currentDateTime.month-1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar(){
    _sequentialDates = CustomCalendar().getMonthCalendar(_currentDateTime.month, _currentDateTime.year, statusdays, startWeekDay: StartWeekDay.monday);
  }

  // show months list
  Widget _showMonthsList(){
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('${_currentDateTime.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),),
          ),
        ),
        Divider(color: Colors.white,),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: (){
                _currentDateTime = DateTime(_currentDateTime.year, index+1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  _monthNames[index],
                  style: TextStyle(fontSize: 18, color: (index == _currentDateTime.month-1) ? Colors.yellow : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  List<Widget> getPlayerinfoforMatch(String email){
    List<Widget> rowcontent = [];

    rowcontent.add(Expanded(
    flex:1,
    child: Text( (allusers.where((u) => u.email == email ).single).Name)
    )
    );
    rowcontent.add(Expanded(
        flex:1,
        child: Text( email)
    )
    );
    return rowcontent;

  }
  // years list views
  Widget _yearsView(int midYear){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _toggleBtn(false),
            Spacer(),
            _toggleBtn(true),
          ],
        ),
        Expanded(
          child: GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index){
                int thisYear;
                if(index < 4){
                  thisYear = midYear - (4 - index);
                }
                else if(index > 4){
                  thisYear = midYear + (index - 4);
                }
                else{
                  thisYear = midYear;
                }
                return ListTile(
                  onTap: (){
                    _currentDateTime = DateTime(thisYear, _currentDateTime.month);
                    _getCalendar();
                    setState(() => _currentView = CalendarViews.months);
                  },
                  title: Text(
                    '$thisYear',
                    style: TextStyle(fontSize: 18, color: (thisYear == _currentDateTime.year) ? Colors.yellow : Colors.white),
                  ),
                );
              }
          ),
        ),
      ],
    );
  }
}
