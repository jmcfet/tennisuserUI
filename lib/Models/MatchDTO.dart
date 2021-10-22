import 'package:json_annotation/json_annotation.dart';
//https://flutter.dev/docs/development/data-and-backend/json#serializing-json-inside-model-classes
//flutter  pub run build_runner build
// https://medium.com/flutter-community/serializing-your-object-in-flutter-ab510f0b8b47
//part 'MatchDTO.g.dart';

@JsonSerializable(nullable: false)


class MatchDTO{
  late int id;
  late int month;
  late int day;
  late int level;
  late String Captain;
 List<String> players =  <String>[];

  MatchDTO({this.id =0,this.month = 1 ,this.day = 1,this.level = 1,this.Captain = '' ,required this.players  });

 // factory MatchDTO.fromJson(Map<String, dynamic> json) =>
 //     _$MatchDTOFromJson(json);
//  Map<String, dynamic> toJson() => _$MatchDTOToJson(this);
   MatchDTO.fromJSON(Map<String, dynamic> json) {

      id =  json['id'] as int ;
      month =  json['month'] as int;
      day =  json['day'] as int;
      level =  json['level'] as int;
      var playersJSON = json['players'];
      Captain = json['Captain'] as String;
      players = new List<String>.from(playersJSON);

  }
}