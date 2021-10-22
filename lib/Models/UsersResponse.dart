
import 'package:login/Models/user.dart';


class UsersResponse {
  List<User> users = <User>[];
  String error = '';


  UsersResponse();
  UsersResponse.mock(List<User> users):
        users  = users,error = "";
}