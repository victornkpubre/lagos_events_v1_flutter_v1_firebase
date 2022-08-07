import 'package:flutter/material.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/reminder.dart';
import 'saved_event_event_page.dart';


class MyEventsPage extends StatefulWidget {
  Size size;
  List<Event> events;
  List<Event> savedEvents = [];
  List<Event> uploadedEvents = [];
  final Function() onMyEventsChanged;


  MyEventsPage({this.events, this.savedEvents,this.uploadedEvents, this.size, @required this.onMyEventsChanged});

  @override
  _MyEventsPageState createState() => _MyEventsPageState(events: events, savedEvents: savedEvents, uploadedEvents: uploadedEvents, size: size, onMyEventsChanged: onMyEventsChanged);
}

class _MyEventsPageState extends State<MyEventsPage> {
  Size size;
  List<Event> events;
  List<Event> savedEvents = [];
  List<Reminder> reminders =[];
  List<Event> uploadedEvents = [];
  

  final Function() onMyEventsChanged;

  static Color greenAccent50 = Color.fromRGBO(89, 234, 193, 0.5);
  double eventIconSize = 15;
  Color checkedColor = greenAccent50;
  Color uncheckedColor = Colors.grey;

  TextStyle eventDetailsStyle = TextStyle(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontFamily: 'poison',
    fontSize: 15
  );

  TextStyle uploadedUnApprovedStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'poison',
    fontSize: 15
  );

  TextStyle uploadedApprovedStyle = TextStyle(
    color: greenAccent50,
    fontFamily: 'poison',
    fontSize: 15
  );

  TextStyle uploadedUnFeaturedStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'poison',
    fontSize: 15
  );

  TextStyle uploadedFeaturedStyle = TextStyle(
    color: greenAccent50,
    fontFamily: 'poison',
    fontSize: 15
  );


  _MyEventsPageState({this.events, this.savedEvents, this.uploadedEvents, this.size, @required this.onMyEventsChanged});

  String feeToString(Event event){
    String feeStr = '';
    event.fees.forEach((r){
      feeStr = feeStr + 'N$r'+ ',  ' ;
    });
    return feeStr;
  }

  String tagsToString(Event event){
    String tagStr = '';
    event.tags.forEach((r){
       if(r != null){
        tagStr = tagStr + '#$r'+ ',  ' ;
       }
    });
    return tagStr;
  }

  String dateToString(Event event){
    return '${event.date.year}-${event.date.month}-${event.date.day}';
  }

  void loadReminders() async{
    DbManager dbManager =DbManager();
    
    reminders = await dbManager.loadReminders();
    
  }

  String eventRemindersToString(Event event){
    String remStr = '';
    reminders.forEach((rem){
      if(rem.eventId == event.id){
        remStr = remStr + rem.name + ', ';
      }
    });
    return remStr;
  }

  @override
  void initState() {
    loadReminders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child:  Column(
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Text('Saved Events', style: eventDetailsStyle,),

              //Saved Events
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: savedEvents.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Divider(color: Colors.transparent,),
                      InkWell( 
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute<Widget>(
                            builder: (BuildContext context) =>SavedEventEventPage(
                              size: size,
                              event: savedEvents[index],
                              reminders: reminders,
                              onEventsChanged: (list){
                                setState(() {
                                  savedEvents.clear();
                                  
                                  List<int> savedEventsId = list;
                                  savedEventsId.forEach((id){
                                    events.forEach((e){
                                      if(e != null){
                                        if(e.id == id){
                                          savedEvents.add(e);
                                        }
                                      }
                                    });
                                  });
                                  onMyEventsChanged();
                                });
                              },
                            )
                          ));
                        },
                        child: Container(
                        color: Color.fromRGBO(15, 57, 68, 1),
                        child: Column(
                          
                          children: <Widget>[
                            ListTile(
                              leading: Container(
                                constraints: BoxConstraints(maxWidth: 100), 
                                child: Image.network(savedEvents[index].imageUrl)
                              ),
                              title: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0), 
                                child:Text(savedEvents[index].title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1)))
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Venue - ', textAlign: TextAlign.left,style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color:Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child: Text(savedEvents[index].venue,  style: TextStyle(fontSize: 12, color: Color.fromRGBO(100, 100, 100, 1))))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text('Date - ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child: Text(dateToString(savedEvents[index]), style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1)),))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text('Gate Fee - ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child:Text(feeToString(savedEvents[index]),  style: TextStyle(fontSize: 11, color:Color.fromRGBO(100, 100, 100, 1))))
                                      ],
                                    ),
                                                       
                                    
                                  ],
                                ),
                              )
                            ),
                            
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                              child: eventRemindersToString(savedEvents[index]).compareTo('')==0? 
                              Text('No Reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))): 
                              Row(children: <Widget>[
                                Text('Reminders : ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                Expanded(child:Text(eventRemindersToString(savedEvents[index]),  style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1))))
                              ],)
                            ),
                            Container(
                              width: size.width*0.8,
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Text(tagsToString(events[index]), textAlign: TextAlign.left, style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1)),),
                            ),
                          ],
                        )
                      )),
                      
                    ],
                  );
                },
              ),

              Divider(color: Colors.transparent,),
              Divider(color: Colors.transparent,),


              Text('Uploaded Events', style: eventDetailsStyle),
              
              //Uploaded Events
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: uploadedEvents.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Divider(color: Colors.transparent,),
                      InkWell( 
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute<Widget>(
                            builder: (BuildContext context) =>SavedEventEventPage(
                              size: size,
                              event: uploadedEvents[index],
                              reminders: reminders,
                              onEventsChanged: (list){
                                setState(() {
                                  uploadedEvents.clear();
                                  
                                  List<int> savedEventsId = list;
                                  savedEventsId.forEach((id){
                                    events.forEach((e){
                                      if(e != null){
                                        if(e.id == id){
                                          uploadedEvents.add(e);
                                        }
                                      }
                                    });
                                  });
                                  onMyEventsChanged();
                                });
                              },
                            )
                          ));
                        },
                        child: Container(
                        color: Color.fromRGBO(15, 57, 68, 1),
                        child: Column(
                          
                          children: <Widget>[
                            ListTile(
                              leading: Container(
                                constraints: BoxConstraints(maxWidth: 100), 
                                child: Image.network(uploadedEvents[index].imageUrl)
                              ),
                              title: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0), 
                                child:Text(uploadedEvents[index].title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1)))
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Venue - ', textAlign: TextAlign.left,style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color:Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child: Text(uploadedEvents[index].venue,  style: TextStyle(fontSize: 12, color: Color.fromRGBO(100, 100, 100, 1))))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text('Date - ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child: Text(dateToString(uploadedEvents[index]), style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1)),))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text('Gate Fee - ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                        Expanded(child:Text(feeToString(uploadedEvents[index]),  style: TextStyle(fontSize: 11, color:Color.fromRGBO(100, 100, 100, 1))))
                                      ],
                                    ),
                                                       
                                    
                                  ],
                                ),
                              )
                            ),
                            
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                              child: eventRemindersToString(uploadedEvents[index]).compareTo('')==0? 
                              Text('No Reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))): 
                              Row(children: <Widget>[
                                Text('Reminders : ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(100, 100, 100, 1))),
                                Expanded(child:Text(eventRemindersToString(uploadedEvents[index]),  style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1))))
                              ],)
                            ),
                            Container(
                              width: size.width*0.8,
                              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: Text(tagsToString(uploadedEvents[index]), textAlign: TextAlign.left, style: TextStyle(fontSize: 11, color: Color.fromRGBO(100, 100, 100, 1)),),
                            ),
                            Container(
                              width: size.width*0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.cloud_upload, size: eventIconSize, color: checkedColor),
                                  Padding(
                                    padding: EdgeInsets.all(2.5),
                                    child: Text('Uploaded', style: uploadedApprovedStyle),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: size.width*0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.check_circle_outline, size: eventIconSize, color: uploadedEvents[index].ranking > 0? checkedColor : uncheckedColor ),
                                  Padding(
                                    padding: EdgeInsets.all(2.5),
                                    child: Text('Approved', style: uploadedEvents[index].ranking > 0? uploadedApprovedStyle : uploadedUnApprovedStyle),
                                  )
                                ],
                              )
                            ),
                            Container(
                              width: size.width*0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.star_border, size: eventIconSize, color: uploadedEvents[index].ranking > 100? checkedColor : uncheckedColor),
                                  Padding(
                                    padding: EdgeInsets.all(2.5),
                                    child: Text('Featured', style: uploadedEvents[index].ranking > 100?
                                     uploadedFeaturedStyle: 
                                     uploadedUnFeaturedStyle),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      )),
                      
                    ],
                  );
                },
              ),



            ],
          )
        ),
        
      ],
    ));
  }
}