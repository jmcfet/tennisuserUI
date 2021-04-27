import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:login/Models/BookDates.dart';
import 'package:login/Models/UserInfo.dart';

import 'globals.dart';
import 'Models/user.dart';
import 'Models/UserResponse.dart';
import 'package:http/http.dart' as http;
import 'Models/UserInfo.dart';
import "Models/MatchDTO.dart";
import "Models/MatchsResponse.dart";
import "Models/BookedDatesResponse.dart";

abstract class BaseAuth {


  Future<UserResponse> signIn(String email, String password);
  Future<UserResponse> register(User user);
  ShowInspector();


}
/*
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUser(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

}
*/

class AuthASP  {
  AuthASP();



  Future<UserResponse> signIn(String userid, String password) async {
    String targethost = '10.0.2.2';

    UserResponse resp = new UserResponse();
    var queryParameters = {
      'username': userid,
      'password': password,

    };
    //we are using asp.net Identity for login/registration. the first time we
    //login we must obtain an OAuth token which we obtain by calling the Token endpoint
    //and pass in the email and password that the user registered with.
    try {

        var gettokenuri = new Uri(scheme: 'http',
            host: 'localhost',
            port: 52175,
      //      host: targethost,
            path: '/Token');

        //the user name and password along with the grant type are passed the body as text.
        //and the contentype must be x-www-form-urlencoded
        var loginInfo = 'UserName=' + userid + '&Password=' + password +
            '&grant_type=password';

        final response = await http
            .post(
              gettokenuri,
              headers: {"Content-Type": "application/x-www-form-urlencoded"},
              body: loginInfo
        );

        if (response.statusCode == 200) {
          resp.error = '200';
          final json = jsonDecode(response.body);
          Globals.token = json['access_token'] as String;
        }
        else {
          //this call will fail if the security stamp for user is null
          resp.error = response.statusCode.toString() + ' ' + response.body;
          return resp;
        }

    }


    catch (e){
      resp.error = e.message;
    }
    return   resp ;

  }


  //this call is has anonymous access so no need for access token. we serialize the user
  //object and send in the HTTP body
  Future<UserResponse> register(User user) async {
    String targethost = '10.0.2.2';
    UserResponse resp = new UserResponse();
    String js;
    js = jsonEncode(user);

    //from the emulator 10.0.2.2 is mapped to 127.0.0.1  in windows

    var url1 = 'http://' + targethost + "/api/Account/Register";
    var url =  'http://localhost:52175/api/Account/Register';
    try {
      // final request = await client.p;
      final response = await http
          .post(url,

          headers: {"Content-Type": "application/json"},
          body: js)
          .then((response) {
        resp.error = '200';
        if ( response.statusCode != 200) {

          resp.error = response.statusCode.toString() + ' ' + response.body;
        }
      });

    }  catch (e) {
      resp.error = e.message;
    }

    return resp;

  }
  Future<UserResponse> SetBookedDatesforuser(String email,int month,List<int> States) async {
    UserResponse resp = new UserResponse();
   UserInfo info = UserInfo();

 //  info.month = month.toString();
   info.values = States;
 //   info.EMail = email;
   String js = jsonEncode(info);
    var queryParameters1 = {
      'month': month.toString(),
      'EMail': email,

    };
    var url = new Uri(scheme: 'http',
      host: 'localhost',
      port: 52175,
      path: '/api/Account/StatusOfDaysinMonth',
      queryParameters: queryParameters1
    );
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
   try {
        final response = await http.post(
          url,
          headers: {HttpHeaders.contentTypeHeader: "application/json",HttpHeaders.authorizationHeader: authorization},
            body: js
        );

       resp.error = '200';
       if ( response.statusCode != 200) {

         resp.error = response.statusCode.toString() + ' ' + response.body;
       }


    }  catch (e) {
        resp.error = e.message;
    }

    return resp;
  }
  Future<String>  GetPlayersinMatch(int day,String Name) async {
 //   BookedDatesResponse resp = new BookedDatesResponse();
    var response;
    String list;
    var queryParameters1 = {
      'Name': Name,
      'day1': "1",

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    var url = new Uri(scheme: 'http',
      host: 'localhost',
      port: 52175,
      path: '/api/Account/GetPlayersinMatch',
        queryParameters:queryParameters1
    );

    try {
      response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
   //   resp.error = error;
  //    return resp;
      return "vvv";
    }
 //   resp.datesandstatus = list.map((model) => BookedDates.fromJson(model)).toList();
 //   return resp;
    return list;
  }
  //this call is needed because we have no control over the token endpoint
  Future<UserResponse>  getUser(String Name) async {
    UserResponse resp = new UserResponse();
    List<MatchDTO> matchinfo = [];
    var response;
    String list;
    var queryParameters1 = {
      'userid': Name,

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    Map usermap;
    try {
      var url = new Uri(scheme: 'http',
          host: 'localhost',
          port: 52175,
          path: '/api/Account/GetUserbyUserID',
          queryParameters:queryParameters1
      );


      response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );
       usermap = json.decode(response.body);

    } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        resp.error = error;
        return resp;
    }
    resp.user = User.fromJson(usermap);
    return  resp;
    //   return resp;

  }

  Future<MatchsResponse>  getMatchsForMonth(int month,String Name) async {
    MatchsResponse resp = new MatchsResponse();
    List<MatchDTO> matchinfo = [];
    var response;
    Iterable list;
    var queryParameters1 = {
      'email': Name,
      'month': month.toString(),

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    try {
    var url = new Uri(scheme: 'http',
        host: 'localhost',
        port: 52175,
        path: '/api/Account/GetMatchesforMonth',
        queryParameters:queryParameters1
    );


      response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error;
      return resp;

    }
    resp.matches = list.map((model) => MatchDTO.fromJSON(model)).toList();
    return  resp;
    //   return resp;

  }
  Future<BookedDatesResponse>  GetMonthStatusforUser(String month,String email) async {
    BookedDatesResponse resp = new BookedDatesResponse();
    var response;
    Map Datesmap;
    var queryParameters1 = {
      'month': month,
      'email': email

    };
    var url = new Uri(scheme: 'http',
        host: 'localhost',
        port: 52175,

        path: '/api/Account/GetMonthStatusforUser',
        queryParameters:queryParameters1
    );
    try {
      response = await http.get(url);
      Datesmap = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error;
      return resp;
    }
    if (Datesmap == null)     //new user
      {
        resp.status = null;
        return resp;
      }
    resp.status = BookDates.fromJSON(Datesmap);
    return resp;
  }
  Future<bool>  isDBFrozen() async {

    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    String authorization = 'Bearer ' + Globals.token;
    var response;
    try {
      var url = new Uri(scheme: 'http',
          host: 'localhost',
          port: 52175,
          path: '/api/Account/isfreezedatabase',

      );


       response = await http.get(url,
          headers: {HttpHeaders.authorizationHeader: authorization}

      );

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
//      resp.error = error;
      return false;
    }
    if (response.statusCode == 200)
            return false;
    return true;

  }

}
