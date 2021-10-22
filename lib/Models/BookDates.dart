import 'package:json_annotation/json_annotation.dart';
//https://flutter.dev/docs/development/data-and-backend/json#serializing-json-inside-model-classes
//flutter  pub run build_runner build
// https://medium.com/flutter-community/serializing-your-object-in-flutter-ab510f0b8b47
//part 'MatchDTO.g.dart';

@JsonSerializable(nullable: false)


class BookDates{
  late int id;
  late int month;
  late int day;
  late int level;
  late String status;

  BookDates({this.id =0,this.month =0,this.day=0,this.level=0,this.status =''  });

  // factory MatchDTO.fromJson(Map<String, dynamic> json) =>
  //     _$MatchDTOFromJson(json);
//  Map<String, dynamic> toJson() => _$MatchDTOToJson(this);
  BookDates.fromJSON(Map<String, dynamic> json) {

    id =  json['id'] as int ;
    month =  json['month'] as int;
//    day =  json['day'] as int;
 //   level =  json['level'] as int;
    status = json['status'];

  }
}