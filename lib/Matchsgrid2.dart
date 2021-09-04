import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:login/Models/MatchDTO.dart';
import 'package:login/Models/UsersResponse.dart';
import 'Calender/Calender.dart';
import 'auth.dart';
import 'Models/user.dart';
import "Models/AllBookedDatesResp.dart";



/// The home page of the application which hosts the datagrid.
class UserMatchsDataGrid2 extends StatefulWidget {
  /// Creates datagrid with selection option(single/multiple and select/unselect)
  ///
  final AuthASP auth;
  final int month;

  UserMatchsDataGrid2({this.auth,this.month } );
  int firstDynamicColumn = 2;
  @override
  _UserMatchsState createState() => _UserMatchsState(auth,month);
}

class _UserMatchsState extends State<UserMatchsDataGrid2> {
  final AuthASP auth;
  int month;
  int currentmonth = 9;
  bool bLoggedIn = true;
  TennisDataGridSource _tennisDataGridSource;
  Map<String,double> columnswidths = Map();
  List<MatchDTO> matchs ;
  List<User> allusers = [];
  List<Calendar> _daysinMonth;


  _UserMatchsState(this.auth,this.month);
  @override
  void initState() {
    super.initState();
    getUsersandInitGrid();

  }

  Future <void> getUsersandInitGrid( ) async {
    DateTime _currentDateTime = DateTime(DateTime.now().year, currentmonth);
    UsersResponse resp =    await auth.getUsers();
    allusers = resp.users;
    var resp1 = await auth.getAllMatchs();
    AllBookedDatesResponse bookingsresp = await auth.getMonthStatus(currentmonth.toString());
    Map<String ,List<int>> subs = new Map<String ,List<int>>();
    matchs = resp1.matches.where((element) => element.month == currentmonth).toList();
    setState(() {
      _tennisDataGridSource = TennisDataGridSource(bLoggedIn);
      _tennisDataGridSource.matchs = matchs;
      _tennisDataGridSource.columns = [];
      MatchDTO last = null;
      List<String> playersinMonth= [];
      int columnNum = 0;
      _tennisDataGridSource.columns.add( 'Name');
      columnswidths['Name'] = 150;
      if (bLoggedIn) {
        _tennisDataGridSource.columns.add('EMail');
        columnswidths['EMail'] = 200;
        _tennisDataGridSource.columns.add('Phone');
        columnswidths['Phone'] = 150;
      }
//use the first bookings for month to get the M-W-F for grid headings
      int day = -1;
      List<String> statusdays = bookingsresp.datesandstatus[0].status.split(',');
      _daysinMonth = CustomCalendar().getJustMonthCalendar(_currentDateTime.month, _currentDateTime.year, statusdays, startWeekDay: StartWeekDay.monday);
      for(int day =0;day < _daysinMonth.length;day++)
      {
        if (_daysinMonth[day].date.month == currentmonth) {
          if (_daysinMonth[day].date.weekday == 1 ||
              _daysinMonth[day].date.weekday == 3 ||
              _daysinMonth[day].date.weekday == 5) {
            if (!_tennisDataGridSource.columns.contains(
                _daysinMonth[day].date.day.toString())) {
              _tennisDataGridSource.columns.add(
                  _daysinMonth[day].date.day.toString());
              columnswidths[_daysinMonth[day].date.day.toString()] = 50;
            }
          }
        }
      }
// loop thru every player who registered for month and their playing status (available,sub, etc) this way we
      //pickup the people who were subs and the ones who were available but were not booked
      bookingsresp.datesandstatus.forEach((booking) {


        PlayerData playerinfo = new PlayerData();
        playerinfo.matches = new List(32);
        bool bActivePlayer = false;
        if (booking.user.phonenum == null)
          booking.user.phonenum = '1111111111';
        playerinfo.name = booking.user.Name;
        playerinfo.email = booking.user.email;
        playerinfo.phonenum = booking.user.phonenum;
        _tennisDataGridSource.allPlayers.add(playerinfo);
        statusdays = booking.status.split(',');
        //create a list of days in month and the players status for that day
        _daysinMonth = CustomCalendar().getJustMonthCalendar(_currentDateTime.month, _currentDateTime.year, statusdays, startWeekDay: StartWeekDay.monday);
        //loop thru all the M-W-F for month states
        int col = 0;

        for(int day =0;day < _daysinMonth.length;day++)
        {
    // if a M-W-F
            if (_daysinMonth[day].date.weekday == 1 ||
                _daysinMonth[day].date.weekday == 3 ||
                _daysinMonth[day].date.weekday == 5) {
                  if (_daysinMonth[day].state == 1) {
                    bActivePlayer = true;
                    playerinfo.matches[col] = 9;    //a sub
                  }
                  if (_daysinMonth[day].state == 0) {
                    findMatch(_daysinMonth[day].date.day,playerinfo,col);
                    bActivePlayer = true;
                  }

                }

          //  }
            col++;
          }

          if (bActivePlayer)
            _tennisDataGridSource.playersinfo.add(playerinfo);
      });
    });
    return ;

  }
findMatch(int day,PlayerData playerinfo,int columnNum){

  List<MatchDTO> matchsforday = matchs.where((element) =>
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
      playerinfo.matches[columnNum] = 8;
  });


}
  @override
  Widget build(BuildContext context) {
    if (_tennisDataGridSource == null)
      return Container();
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(' September Matchs  Blue = Captain '),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.play_circle_filled),
              onPressed: () {
                createPDF();;
              },
            )],
        ),
        body:  SfDataGrid(
            headerRowHeight: 40,
            rowHeight: 40,

            source: _tennisDataGridSource,
            columns: _tennisDataGridSource.columns
                .map<GridColumn>((columnName) => GridTextColumn(
                columnName: columnName,
                width: columnswidths[columnName],
                label: Container(
                  padding: EdgeInsets.all(3),
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Text(

                    columnName.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                )
            )
            )
                .toList()
        )
    );

  }
}
createPDF(){

}
class TennisDataGridSource extends DataGridSource {
  List<String> columns = [];

  List<MatchDTO> matchs;
  List<DataGridRow> _matchData = [];
  List<PlayerData> playersinfo = [];
  List<PlayerData> allPlayers = [];
  bool bLoggedIn;
  TennisDataGridSource(this.bLoggedIn);

  @override
  List<DataGridRow> get rows =>
      playersinfo.map<DataGridRow>((e) {
        List<DataGridCell> cells = [];
        cells.add(DataGridCell<String>(columnName: 'Name', value: e.name),);
        if (bLoggedIn){
               cells.add(DataGridCell<String>(
                   columnName: 'EMail', value: e.email));
              cells.add(DataGridCell<String>(
                  columnName: 'Phone', value: e.phonenum));
        }

        this.columns.forEach((element) {
          //only the dynamic columns have a numeric value
          int columnNum = int.tryParse(element) ?? -1;
          if (columnNum != -1){
            columnNum =  columnNum -1;     //old zero offset
            cells.add(DataGridCell<String>(

                columnName: element, value: e.matches[columnNum].toString()));
          }

        });

        return DataGridRow(
            cells: cells);
      }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    var playerName = row.getCells()[0].value;
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
          Color getColor() {
            int columnNum = int.tryParse(dataGridCell.columnName) ?? -1;
            if (columnNum != -1) {
              PlayerData data = allPlayers.where((element) => element.name == playerName).single;;
              if (data.CaptainthatDay[columnNum-1] == 1)
                return Colors.blue;

            }
            if (columnNum == -1)
              return Colors.grey;
            return Colors.transparent;
          }
          String content = dataGridCell.value;

          if (dataGridCell.value == '9' )
            content = 'S';
          if (dataGridCell.value == '8' )
            content = 'A';
          if (dataGridCell.value == "null" )
            content = '-';
          return Container(
              color: getColor(),
              alignment:
              Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                  child:Text(

                    content,
                    textAlign:TextAlign.center,
                    overflow: TextOverflow.ellipsis,

                  ))
          );

        }).toList());
  }

}

class PlayerData{
  String name;
  String email;
  String phonenum;
  bool IsCaptain;
  List<int> matches = [];
  List<int> CaptainthatDay = [];
  PlayerData(){
    IsCaptain = false;

    for (int i = 0; i < 32; i ++) {
      matches.add(-1);
      CaptainthatDay.add(-1);
    }
  }
}
