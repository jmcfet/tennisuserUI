
import "BookDates.dart";


class BookedDatesResponse {
  BookDates status;
  String error;


  BookedDatesResponse();
  BookedDatesResponse.mock(String status):
        status  = null,error = "";
}