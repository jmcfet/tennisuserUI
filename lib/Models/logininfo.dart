class loginInfo {
   String Username;
   String Password;
   Map<String, dynamic> toJson() =>
       {
         //    'month': month,
         //    'EMail':EMail,
         'UserName': Username,
          'Password':Password
       };
}