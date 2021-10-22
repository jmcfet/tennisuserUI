import 'package:json_annotation/json_annotation.dart';

import 'user.dart';
//https://flutter.dev/docs/development/data-and-backend/json#serializing-json-inside-model-classes
//flutter  pub run build_runner build
part 'PlayersinfoandBookedDate.g.dart';

@JsonSerializable(nullable: false)
class PlayersinfoandBookedDates{
  late int Id;
  late User user;
  late int Month;
  late int day;
  late String status;
  late bool bIsCaptain = false;
//  int  timesCaptain;


  // ignore: non_constant_identifier_names
  PlayersinfoandBookedDates ({required this.Id ,  required this.Month,required this.status,required this.bIsCaptain,required this.day, required this.user});
  // ({this.Id,   this.Name,this.Month,this.status,this.timesCaptain,this.bIsCaptain,this.level,this.day,this.user});

  // factory PlayersinfoandBookedDates.fromJson(Map<String, dynamic> json) =>
  //     _$PlayersinfoandBookedDatesFromJson(json);
  //handle the embedded user object
  factory PlayersinfoandBookedDates.fromJson(Map<String, dynamic> json){
    var obj = PlayersinfoandBookedDates(
        Id: json['Id'] == null ? 0:json['Id'] as int,
        Month: json['month'] as int,
        status: json['status'] as String,
        bIsCaptain: false,
        day: 2,
        user: User.fromJson(json['user'])
    );

    return obj;

  }
  Map<String, dynamic> toJson() => _$PlayersinfoandBookedDatesToJson(this);

}