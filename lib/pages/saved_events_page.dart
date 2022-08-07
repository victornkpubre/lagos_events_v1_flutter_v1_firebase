import 'package:flutter/material.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';
import 'my_event_page.dart';


class SavedEventsPage extends StatefulWidget {
  Size size;
  List<Event> events;

  SavedEventsPage({this.size, this.events});  

  @override
  _SavedEventsPageState createState() => _SavedEventsPageState(size: size, events: events);
}

class _SavedEventsPageState extends State<SavedEventsPage> {

  Size size;
  List<Event> events;
  List<Event> savedEvents = [];
  List<Event> savedEvents_master = [];
  List<Event> uploadedEvents = [];
  List<Event> uploadedEvents_master = [];

  bool filtering = false;
  bool sorting = false;

  DateTime minDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime maxDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: 7));

  double minFee = 0;
  double maxFee = 100000;

  String sortingState = 'None';

  _SavedEventsPageState({this.size, this.events});


  void loadUploadedEvents() async{
    DbManager dbManager =DbManager();
    List<int> uploadedEventsId = [];

    //dbManager.clearUploadedEvents();
    uploadedEventsId = await dbManager.loadUploadedEvents().then((onValue){
     setState((){
      uploadedEventsId = onValue;
      uploadedEventsId.forEach((id){
        events.forEach((e){
          if(e != null){
            if(e.id == id){
              uploadedEvents.add(e);
            }
          }
        });
      }); 
     });   
     uploadedEvents_master = uploadedEvents;
     return uploadedEventsId;
    });    
  }

  void loadSavedEvents() async{
    DbManager dbManager =DbManager();
    List<int> savedEventsId = [];

    savedEventsId = await dbManager.loadSavedEvents().then((onValue){
     setState((){
      savedEventsId = onValue;
      savedEventsId.forEach((id){
        events.forEach((e){
          if(e != null){
            if(e.id == id){
              savedEvents.add(e);
            }
          }
        });
      }); 
     });   
     savedEvents_master = savedEvents;
     return savedEventsId;
    });    
  }


  @override
  void initState() {
    loadUploadedEvents();
    loadSavedEvents();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
                  child: Column(              
                    children: <Widget>[
                      Container(
                        width: size.width,
                        height: size.height*0.7,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: <Widget>[
                            Divider(
                              color: Color.fromRGBO(89, 234, 193, 1.0),
                              height: 15.0,
                              thickness: 2.0,
                            ), 
                            Expanded(
                              child: Container(
                                //List of Events
                                child:  MyEventsPage(events: events, savedEvents: savedEvents, uploadedEvents: uploadedEvents, size: size, onMyEventsChanged: (){setState(() {});},),
                              )
                            )
                          ],
                        )
                      )
                      
                    ],
                  )
                );
  }
}