
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
  final AuthASP? auth;
  final bool viewOnlyMode ;
  int month;
  CalenderHome({this.auth,required this.viewOnlyMode,required this.month});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<CalenderHome> {



  List<Calendar> _sequentialDates =  <Calendar>[];
  int midYear =1;
  CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  final List<String> _monthNames = ['fillsonot0based','January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  List<int> States = <int>[];
  List<MatchDTO>? matches = [];
  String existingBookings = '';
  List<String> statusdays = [];
  List<User> allusers = [];
  bool saveButtonEnabled = true;
  int defaultStatus = 2;
  bool longPress = false;
  DateTime? _currentDateTime;
  DateTime? _selectedDateTime;
//  static FileService fileservice = new FileService();
  @override
  void initState()  {
    super.initState();
    final date = DateTime.now();
    _currentDateTime = DateTime(date.year, widget.month);
    _selectedDateTime =  DateTime(date.year, widget.month, date.day);

//    getDBState();
    if (widget.viewOnlyMode == true) {   //viewing previous month that has been scheduled so need user info for matches
      getuserinfo();
      getallUsers();
    }

     getBookDates(widget.month);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future <String> getuserinfo( ) async {
    MatchsResponse resp =   await widget.auth!.getMatchsForMonth(widget.month, Globals.user!.email);
    matches = resp.matches;
 //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      setState(() => _getCalendar());
 //   });
    return 'done';
  }
  //get the status of each bookable day in the month. e,g june 5 is unavailable
  Future <String> getBookDates(int month ) async {
    BookedDatesResponse resp =   await widget.auth!.GetMonthStatusforUser(month.toString(), Globals.user!.email);

      if (!resp!.errormessage.isEmpty)       //if an exception was thrown tell user
      {
        AwesomeDialog(
          context: context,
          animType: AnimType.LEFTSLIDE,
          headerAnimationLoop: false,
          dialogType: DialogType.INFO,
          title: resp.errormessage,
          autoHide: Duration(seconds: 20),
        )
          ..show();
        return 'failed';

      }

    if (resp.status != null) {      //there might have been no data for user

      statusdays = resp.status!.status.split(',');
      return 'ok';
    }

    return 'failed';
  }
  Future <void> getallUsers( ) async {
    UsersResponse resp =    await widget.auth!.getUsers();
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
            child:  _datesView()

        ),

      ),
    );
  }

  // dates view
  Widget _datesView(){
    String title = Globals.user!.Name! + ' ' +  _monthNames[_currentDateTime!.month] + ' ' ;
    if (!widget.viewOnlyMode)
     title = Globals.user!.Name!   + ' ' + _monthNames[_currentDateTime!.month] + ' ' ;

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
        widget.viewOnlyMode == false &&   statusdays.length == 0  ?  Row(
          children: [
            Text(
                'Set all days to ',
                style: TextStyle(
                  color: Colors.white,
                ),

            ),
            defaultStatus !=0   ? makeButton(Colors.green,() {
              setState(() {
                defaultStatus = 0;
                _getCalendar();
              } );
            },) :Container(),

            Text(
              ' ',
              style: TextStyle(
                color: Colors.white,
              ),

            ),
            defaultStatus !=1 && statusdays.length == 0   ? makeButton(Colors.yellow,() {
              setState(() {
                defaultStatus = 1;
                _getCalendar();
              } );
              },)
                :Container(),

             Text(
              ' ',
              style: TextStyle(
                color: Colors.white,
              ),

            ),
            defaultStatus !=2  && statusdays.length == 0 ? makeButton(Colors.grey,() {
              setState(() {
                defaultStatus = 2;
                _getCalendar();
              } );
            }
            )
            :Container(),


          ],

        ) : Container(),
   //     SizedBox(height: 20,),
        Divider(color: Colors.white,),
        SizedBox(height: 20,),
        Flexible(child: _calendarBody()),
        SizedBox(height: 20,),
        widget.viewOnlyMode == false ? LegendScheduler() : LegendShowSchedule()

      ],
    );
  }

  // next / prev month buttons
  Widget _toggleBtn(bool next) {
    if (widget.viewOnlyMode == false)
      return Container();
    return InkWell(
      onTap: () async{

          if (widget.viewOnlyMode){
            (next) ? _getNextMonth() : _getPrevMonth();

          }
          //get the users booking for this new month
          String rc = await getBookDates(_currentDateTime!.month);
          if (rc == 'failed'){
              AwesomeDialog(
                context: context,
                animType: AnimType.LEFTSLIDE,
                headerAnimationLoop: false,
                dialogType: DialogType.INFO,
                title: 'no data for month',
                autoHide: Duration(seconds: 2),
              )
                ..show();
              return ;

            }

          //get their matchs
          MatchsResponse? resp = await widget.auth?.getMatchsForMonth(_currentDateTime!.month, Globals.user!.email);
          matches = resp!.matches;
          //setup calender
          _sequentialDates = CustomCalendar().getMonthCalendar(_currentDateTime!.month, _currentDateTime!.year, statusdays,defaultStatus, startWeekDay: StartWeekDay.monday);
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
    if (widget.viewOnlyMode == true )
      return Container();
    return ElevatedButton(
        child: Text("Save Changes", style: TextStyle(fontSize: 20),),

        onPressed:  () async{
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

           UserResponse? resp = await widget.auth?.SetBookedDatesforuser(Globals.user!.email,_currentDateTime!.month,States);
           if (resp!.error == '200')
             {
               AwesomeDialog(
                   context: context,
                   animType: AnimType.LEFTSLIDE,
                   headerAnimationLoop: false,
                   dialogType: DialogType.INFO,
                   title: 'changes saved',
                   autoHide: Duration(seconds: 6),
               )
                 ..show();


             }
      },

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
          if (!widget.viewOnlyMode){
              if (date1.thisMonth) {
                if (date1.date!.weekday == 1 ||
                   date1.date!.weekday == 3 ||
                  date1.date!.weekday == 5
                ) {
                  if (date1.state == -1)
                    return _calendarDates(date1);
                  else
                    return _selector(date1, false);

                }
           }
          }
          else {
            MatchDTO? m = matches!.firstWhereOrNull((element) =>
            element.day == date1.date!.day);
            if (m == null)
              return _calendarDates(_sequentialDates[index - 7]);
            bool bisCaptain = false;
            if (m.Captain == Globals.user!.Name)
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
        height:80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              makeButton(Colors.yellow,(){}),
              Text(
                ' Sub',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              makeButton(Colors.green,(){}),
              Text(
                ' Available',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              makeButton(Colors.grey,(){}),
              Text(
                ' Unavailable',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                child: Text(
                  "tap circled date to change status press SAVE CHANGES to save ",
                  style: TextStyle(color: Colors.white),
                  //         textAlign: TextAlign.center,
                ),
              )
            ]),
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
            '${calendarDate.date!.day}',
            style: TextStyle(
              color: (calendarDate.thisMonth)
                  ? (calendarDate.date!.weekday == DateTime.sunday) ? Colors.yellow : Colors.white
                  : (calendarDate.date!.weekday == DateTime.sunday) ? Colors.yellow.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            ),
          )
      ),
    );
  }

  // date selector
  Widget _selector(Calendar calendarDate,bool bCaptain) {
    var currentColor;
  //  int state =_sequentialDates[calendarDate.date.day].state;

 //   if(States[calendarDate.date.day]  == null)
 //     States[calendarDate.date.day] = 0;
    switch (calendarDate.state){
      case 0:
        currentColor = bCaptain == true ?  Colors.red.withOpacity(0.9):
        Colors.green.withOpacity(0.9);
        break;
      case  1:
        currentColor = Colors.yellow;
        break;
      case  2:
        currentColor = Colors.grey;
        break;
      default:
        break;


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
            child: Text( '${calendarDate.date!.day}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            onPressed: ()  {
              selectedDate = calendarDate.date!.day;
              if (!widget.viewOnlyMode) {
         //       showChoices();
  //              if (longPress == true) {
  //                Calendar selectedday = _sequentialDates.where((element) => element.date.month == _currentDateTime.month &&
  //                    element.date.day == selectedDate).singleOrNull;
 //                 setState((){selectedday.state = defaultStatus;});

  //              }
  //               else
                    _showSingleChoiceDialog(context,calendarDate.state);

                return;
              }
             //    .then((value) async{
              //      if (_sequentialDates[selectedDate].state == 8){
              MatchDTO? m = matches!.firstWhereOrNull((element) => element.day == selectedDate);

              showPlayers(m);

            }
          )
      ),
    );


  }
  final List<String> states = ['available','unavailable', 'sub'     ];
  String currentChoice = '';
  int selectedDate = 0;
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
                           Calendar? selectedday = _sequentialDates.where((element) => element.date!.month == _currentDateTime!.month &&
                               element.date!.day == selectedDate).singleOrNull;
                           switch (value) {
                             case 'available':
                                selectedday!.state = 0;
                                break;
                              case 'sub':
                                selectedday!.state = 1;
                                break;
                              case 'unavailable':
                                selectedday!.state = 2;
                                break;
                              case 'match':
                                selectedday!.state = 8;
                                break;
                              default:
                                selectedday!.state = 0;
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
  showPlayers(MatchDTO? m){
    AwesomeDialog? dialog ;
     dialog =
      AwesomeDialog(
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
                    getPlayerinfoforMatch(m!.players[0])
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
                  dialog?.dissmiss();
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
                                Calendar? selectedday = _sequentialDates.where((element) => element.date!.month == _currentDateTime!.month &&
                                    element.date!.day == selectedDate).singleOrNull;
                                switch (value) {
                                  case 'available':
                                    selectedday!.state = 0;
                                    break;
                                  case 'sub':
                                    selectedday!.state = 1;
                                    break;
                                  case 'unavailable':
                                    selectedday!.state = 2;
                                    break;
                                  case 'match':
                                    selectedday!.state = 8;
                                    break;
                                  default:
                                    selectedday!.state = 0;
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
    if(_currentDateTime!.month == 12) {
      _currentDateTime = DateTime(_currentDateTime!.year+1, 1);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime!.year, _currentDateTime!.month+1);
    }


  }

  // get previous month calendar
  void _getPrevMonth(){
    if(_currentDateTime!.month == 1){
      _currentDateTime = DateTime(_currentDateTime!.year-1, 12);
    }
    else{
      _currentDateTime = DateTime(_currentDateTime!.year, _currentDateTime!.month-1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar(){
    _sequentialDates = CustomCalendar().getMonthCalendar(_currentDateTime!.month, _currentDateTime!.year, statusdays,defaultStatus, startWeekDay: StartWeekDay.monday);
  }

  // show months list
  Widget _showMonthsList(){
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('${_currentDateTime!.year}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),),
          ),
        ),
        Divider(color: Colors.white,),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: (){
                _currentDateTime = DateTime(_currentDateTime!.year, index+1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  _monthNames[index],
                  style: TextStyle(fontSize: 18, color: (index == _currentDateTime!.month-1) ? Colors.yellow : Colors.white),
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
    var number = '';
    var user = allusers.where((u) => u.email == email ).single;
    if (user.phonenum != null)
      number = user.phonenum!;
    rowcontent.add(Expanded(
    flex:1,
    child: Text( user.Name as String)
    )
    );
    rowcontent.add(Expanded(
        flex:1,
        child: Text( email + ' ' + number)
    )
    );
    return rowcontent;

  }


  Widget makeButton(currentColor,VoidCallback performAction){
    return
      ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 30, height: 30),
          child:
          ElevatedButton(
              onPressed: performAction,
  //            onLongPress: (){
  //              longPress = true;
  //              if (currentColor ==  Colors.green)
  //                  defaultStatus = 0;
  //              else if (currentColor == Colors.yellow)
  //                  defaultStatus = 1;
   //             else
  //                  defaultStatus = 2;

   //           },
              style: ElevatedButton.styleFrom(
                  primary: currentColor, // background

                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),

                  )
              ), child: null,
          )
      );

  }


}
