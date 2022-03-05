
import "BookDates.dart";


class BookedDatesResponse {
  BookDates? status;
  String errormessage = '';
  int HTTPCode = 200;


  BookedDatesResponse();
  BookedDatesResponse.mock(String status):
        status  = null,errormessage = "",HTTPCode = 200;
}