class UserInfo {
 // String month;
 // String EMail;
  List<int> values = <int>[];
  Map<String, dynamic> toJson() =>
      {
    //    'month': month,
    //    'EMail':EMail,
        'status': values,

      };
}