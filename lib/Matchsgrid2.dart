import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:html';

import 'package:syncfusion_flutter_pdf/pdf.dart';



/// The home page of the application which hosts the datagrid.
class UserMatchsDataGrid2 extends StatefulWidget {
  /// Creates datagrid with selection option(single/multiple and select/unselect)
  ///
  List<PlayerData> playersinfo = [];
  List<PlayerData> allPlayers = [];
  List<String> columns = [];
  int currentmonth = 0;
  Map<String,double> columnswidths = Map();

  UserMatchsDataGrid2({required List<PlayerData> playersinfoin,required List<PlayerData> allPlayersin,required int monthin,required List<String> columnsin,
  required Map<String,double> columnwidthsin})
  {
    playersinfo = playersinfoin;
    currentmonth = monthin;
    allPlayers = allPlayersin;
    columns = columnsin;
    columnswidths = columnwidthsin;
  }
  int firstDynamicColumn = 2;
  @override
  _UserMatchsState createState() => _UserMatchsState();
}

class _UserMatchsState extends State<UserMatchsDataGrid2> {

  GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  bool bLoggedIn = true;
  late TennisDataGridSource _tennisDataGridSource;

  final List<String> _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];


  @override
  void initState() {
    super.initState();
    _tennisDataGridSource = TennisDataGridSource(playersinfo: widget.playersinfo, bLoggedIn: bLoggedIn, allPlayersin: widget.allPlayers, columns: widget.columns);
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(_monthNames[widget.currentmonth-1] + '  Matchs  '),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Export To Pdf'),
              onPressed: () {
                createPDF();;
              },
            )],
        ),
        body:  SfDataGrid(
            headerRowHeight: 40,
            rowHeight: 40,
            key:_key,
            source: _tennisDataGridSource,
            columns: widget.columns
                .map<GridColumn>((columnName) => GridColumn(
                columnName: columnName,
                width: widget.columnswidths[columnName] as double,
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
   createPDF( ) async{
  //   PdfDocument document = _key.currentState!.exportToPdfDocument();
     //                 final List<int> bytes = document.save();
     //                 File(bytes,'DataGrid.pdf');
     //                await saveAndLaunchFile(bytes, 'DataGrid.pdf');
     //to produce landscape we need to create a pdfgrid first
     PdfDocument document = PdfDocument(

     );
     document.pageSettings.orientation = PdfPageOrientation.landscape;
     PdfPage pdfPage = document.pages.add();
     PdfGrid pdfGrid = _key.currentState!.exportToPdfGrid(

       cellExport: (DataGridCellPdfExportDetails details) {

         int columnNum = int.tryParse(details.columnName) ?? -1;   //only look for Captain in numeric columns
         if (columnNum != -1 && details.cellType == DataGridExportCellType.row) {
           String tt = details.cellValue as String;
           int found = tt.indexOf('C');
           if (found != -1) {

             details.pdfCell.value  = details.pdfCell.value.substring(0,details.pdfCell.value.length - 1);   //emove the C
             details.pdfCell.style.backgroundBrush = PdfBrushes.lightGray;    //make the cell gray
           }
         }
       },
     );
     pdfGrid.draw(
         page: pdfPage,
         bounds: Rect.fromLTWH(0, 0, 0, 0));
     final List<int> bytes = document.save();

     await saveAndLaunchFile(bytes, _monthNames[widget.currentmonth-1] +'DataGrid.pdf');
     document.dispose();
  }
}





class TennisDataGridSource extends DataGridSource {

  List<PlayerData> allPlayers = [];
  TennisDataGridSource({required List<PlayerData> playersinfo,required bLoggedIn,required List<PlayerData> allPlayersin,required List<String> columns }) {
    allPlayers = allPlayersin;
    dataGridRows = playersinfo
        .map<DataGridRow>((e) {
      List<DataGridCell> cells = [];

      cells.add(DataGridCell<String>(columnName: 'Name', value: e.name),);
      if (bLoggedIn){
        var number = e.phonenum.substring(0,3) + '-' +e.phonenum.substring(3);
        cells.add(DataGridCell<String>(
            columnName: 'EMail', value: e.email));
        cells.add(DataGridCell<String>(
            columnName: 'Phone', value: number));
      }
// add the dynnamic columns
      columns.forEach((element) {
        bool bSpecial = false;
        //only the dynamic columns have a numeric value
        int columnNum = int.tryParse(element) ?? -1;
        if (columnNum != -1){
          columnNum =  columnNum -1;     //old zero offset
          String matchs = e.matches[columnNum].toString();
          if (matchs == '9' ){
            bSpecial = true;
            matchs = 'S';     //a sub
          }
          if (matchs == '8' ) {
            bSpecial = true;    //available
            matchs = 'A';
          }
          if (matchs == '0' ){
            bSpecial = true;
            matchs = '';
          }
           if ( !bSpecial) {
             PlayerData data = allPlayers
                 .where((element) => element.name == e.name)
                 .single;

             if (data.CaptainthatDay[columnNum] == 1)
               matchs += 'C';
           }

          cells.add(DataGridCell<String>(

              columnName: element, value: matchs));
        }

      });

      return DataGridRow(
          cells: cells);
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var playerName = row.getCells()[0].value;
    int column = 0;
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {

     //     var temp = row.getCells()[i++].value;
          String content = dataGridCell.value;
          Color cellColor = Colors.transparent;
          if (++column  > 2)
            {    //PDF will see C beside the match number
              int index = content.indexOf('C');
              if (index != -1) {
                cellColor = Colors.black12;
                content  = content.substring(0,content.length - 1);
              }

            }
          return Container(
              color: cellColor,
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
  String name = '';
  String email = '';
  String phonenum = '';
  bool IsCaptain = false;
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

//  NOTE THIS ONLY WORKS IN FLUTTER WEB BUT THAT IS MY TARGET NOW
Future<void> saveAndLaunchFile(
    List<int> bytes, String fileName) async {
  AnchorElement(
      href:
      'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(
          bytes)}')
    ..setAttribute('download', fileName)
    ..click();


}

