class UserInfo {
 // String month;
 // String EMail;
  List<int> values;
  Map<String, dynamic> toJson() =>
      {
    //    'month': month,
    //    'EMail':EMail,
        'status': values,

      };
}