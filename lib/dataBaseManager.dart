import 'dart:convert';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbManager{

  DbManager();





//***********        SavedEvents Utility Functions                      **********//

  Future<List<int>> loadSavedEvents() async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     if(prefs.containsKey('savedEvents')){
       String jsonStr = prefs.getString('savedEvents');  
       list = json.decode(jsonStr);
       list1 = list.cast<int>();
       return list1;
     }
     else{
       prefs.setString('savedEvents', '[]');
       return new List<int>();
     } 
  }

  Future<List<int>> addSavedEvent(Event event) async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     list = json.decode( prefs.getString('savedEvents') );
     list.add(event.id);
     prefs.setString('savedEvents', json.encode(list));
     list1 = list.cast<int>();
     return list1;
  }

  Future<List<int>> removeSavedEvent(Event event) async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     list = json.decode( prefs.getString('savedEvents') );
     list.remove(event.id);
     prefs.setString('savedEvents', json.encode(list));
     list1 = list.cast<int>();
     return list1;
  }

  bool isSavedEvent(Event event,  List<int> eventList){
     bool con = false;
     eventList.forEach((id){
       if(event.id == id){
         con = true;
       }
     });
     return con;  
  }


  //***********        Uploaded Events Utility Functions                      **********//

  Future<List<int>> loadUploadedEvents() async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     if(prefs.containsKey('uploadedEvents')){
       String jsonStr = prefs.getString('uploadedEvents');  
       list = json.decode(jsonStr);
       list1 = list.cast<int>();
       return list1;
     }
     else{
       prefs.setString('uploadedEvents', '[]');
       list1 = list.cast<int>();
       return list1;
     } 
  }

  Future<List<int>> addUploadedEvent(int event_id) async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     list = json.decode( prefs.getString('uploadedEvents') );
     list.add(event_id);
     prefs.setString('uploadedEvents', json.encode(list));
     list1 = list.cast<int>();
     return list1;
  }

  Future<List<int>> removeUploadedEvent(int event_id) async {
     List<dynamic> list;
     List<int> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     list = json.decode( prefs.getString('uploadedEvents') );
     list.remove(event_id);
     prefs.setString('uploadedEvents', json.encode(list));
     list1 = list.cast<int>();
     return list1;
  }

  bool isUploadedEvent(int event_id,  List<int> uploadedList){
     bool con = false;
     uploadedList.forEach((id){
       if(event_id == id){
         con = true;
       }
     });
     return con;  
  }

  void clearUploadedEvents() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uploadedEvents', '[]');

  }





  //***********        Reminder Utility Functions                      **********//
  List<Reminder> mapListToReminderList(List<dynamic> maps){
      List<Reminder> rem = [];
      maps.forEach((dynamic currentMap){
        Reminder reminder = Reminder(
          name: currentMap['name'],
          alertId: currentMap['alertId'],
          eventId: currentMap['eventId'],
          alertTimeYear: currentMap['alertTimeYear'],
          alertTimeMonth: currentMap['alertTimeMonth'],
          alertTimeDay: currentMap['alertTimeDay'],
          alertTimeHour: currentMap['alertTimeHour']
        );
        rem.add(reminder);
      });
      return rem;
  }

  Future<List<Reminder>> loadReminders() async {
     List<dynamic> list;
     List<Reminder> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     if(prefs.containsKey('reminders')){
       String jsonStr = prefs.getString('reminders');  
       list = json.decode(jsonStr);
       list1 =  mapListToReminderList(list);
       return list1;
     }
     else{
       prefs.setString('reminders', '[]');
       return new List<Reminder>();
     } 
  }

  Future<List<Reminder>> addReminder(List<Reminder> reminders, Reminder reminder) async {
     List<Reminder> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     prefs.setString('reminders', json.encode(reminders));
     list1 = reminders.cast<Reminder>();
     return list1;
  }

  Future<List<Reminder>> removeReminder(List<Reminder> reminders, Reminder reminder) async {
     List<Reminder> list1;
     SharedPreferences prefs = await SharedPreferences.getInstance();

     prefs.setString('reminders', json.encode(reminders));
     list1 = reminders.cast<Reminder>();
     return list1;
  }

  void clearReminders() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('reminders','[]');
    prefs.clear();
  }

  bool isReminderSet(String reminder, Event event, List<Reminder> reminders){
    bool con = false;
    reminders.forEach((Reminder rem){
      if(rem.eventId==event.id  &&  rem.name.compareTo(reminder)==0){
        con = true;
      }
    });
    return con;
  }

}