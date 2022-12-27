  
import 'package:intl/intl.dart';


class AdvancedQuerry {
  //method 1
  //advanced search pram
  List<String> advancedSearch({required String? query}) {

    if (query == null) 
      return [];

    String temp = "";
    List<String> bucket = [];

    for (int i = 0; i < query.length; i++) {
      temp += query[i];
      bucket.add(temp);
    }

    return bucket;
  }

  //method 2
  //advanced hash tags
List<String> advancedHashTags({required String hashTags}) {
    hashTags+= " ";
    String newStr = "";
    String temp = "";
    int j = 0;
    //int distince = 0;
    List<String> bucket = [];
    //set all to lower
    for (int i = 0; i < hashTags.length; i++) {
      newStr += hashTags[i].toLowerCase();
    }
    print("The new Str is $newStr\n");
    // a for loop that runs with I and checks for a "#" char. if found seperate "#" to " " (a white space). 
    // a sub has prams (int pos, int location)
    for (int i = 0; i < newStr.length; i++) {
      for (int j = i+1; j < newStr.length; j++){
        if (newStr[i] == '#' && newStr[j] == ' '){
          temp = newStr.substring(i,j);
          bucket.add(temp);
          print("Passed");
          break;
        }
      }
      
    }
    print("done, did anything print?");
    return bucket;
  }
  //check that every username is unique
  //may end up doing this in screen instead
}

//==================================================================================================

final DateFormat timeFormat = DateFormat('E, h:mm a');
