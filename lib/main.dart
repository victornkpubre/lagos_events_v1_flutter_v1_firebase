import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/pages/about_app.dart';
import 'package:lagos_events/pages/events_event_page.dart';
import 'package:lagos_events/pages/events_page.dart';
import 'package:lagos_events/pages/privacy_policy_page.dart';
import 'package:lagos_events/pages/saved_events_page.dart';
import 'package:lagos_events/pages/upload_page.dart';
import 'package:lagos_events/reminder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_database/firebase_database.dart' as firebase_datebase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Color.fromRGBO(186, 164, 225, 0.3));
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(89, 234, 193, 1.0),
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int lastEventId;
  List<Event> events = [];
  List<Event> events_master = [];
  Map<int, Event> eventsMap = {};
  List<Event> currentEvents = [];
  List<int> savedEvents= [];
  List<Reminder> reminders = [];
  List<String> tags = [];
  Map< DateTime, List > eventsDateMap = {};
  CalendarController _controller = CalendarController();
  DefaultTabController tabController;

  //Contact
  static const String lagos_events_contact_number = '08090659632';


  //State Vars
  String title = 'Lagos Events';

  //Firebase  Refs 
  final firebase_datebase.DatabaseReference database = firebase_datebase.FirebaseDatabase.instance.reference().child("events_db");
  final firebase_datebase.DatabaseReference lastEventIdRef = firebase_datebase.FirebaseDatabase.instance.reference().child("events_db").child("last_event_id");
  final firebase_datebase.DatabaseReference lastTagIdRef = firebase_datebase.FirebaseDatabase.instance.reference().child("events_db").child("last_tag_id");
  final firebase_datebase.DatabaseReference eventsRef = firebase_datebase.FirebaseDatabase.instance.reference().child("events_db").child("events");
  final firebase_datebase.DatabaseReference tagsRef = firebase_datebase.FirebaseDatabase.instance.reference().child("events_db").child("tags");
  
  //Styles
  static Color purpleTint = Color.fromRGBO(194, 174, 225, 1);
  static Color purpleTint50 = Color.fromRGBO(186, 164, 225, 0.8);
  static Color greenAccent = Color.fromRGBO(89, 234, 193, 1);

  TextStyle titleStyle = TextStyle(
    color: purpleTint,
    fontFamily: 'Sacramento',
    fontWeight: FontWeight.w500,
    fontSize: 30,
  );
  TextStyle tabHeaderStyle = TextStyle(
    color: purpleTint,
  );
  TextStyle eventDetailsStyle = TextStyle(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontFamily: 'poison',
    fontSize: 9
    
  );
  TextStyle eventDetailsStyleH1 = TextStyle(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontFamily: 'MontaseliSans',
    fontSize: 18
  );
  TextStyle drawerStyle = TextStyle(
    color: Colors.grey,
    fontSize: 16
  );
  TextStyle drawerStyleH3 = TextStyle(
    color: Colors.grey,
    fontSize: 12
  );
  




  //***   Event Id Function   ***//
  Future<void> loadLastId() async{
    await lastEventIdRef.once().then((firebase_datebase.DataSnapshot snapshot){
      lastEventId = snapshot.value['id'];
      print(lastEventId);
    });
  }
  void setLastId(int id){
    lastEventIdRef.set({'id' : id});
  }




  //***     Download Functions    ****//
  Future<List<void>> loadTags() async{
    int tags_cnt;
    Map<int,String> tagMap = {};

    await lastTagIdRef.child('id').once().then((firebase_datebase.DataSnapshot snapshot) async{
      tags_cnt = snapshot.value;
      tagMap = {};
      for (var i = 0; i < tags_cnt; i++) {
        int index = i+1;
        await tagsRef.child('$index').once().then((firebase_datebase.DataSnapshot snapshot){
          if(snapshot.value == null){
            tagMap[index] = "";
          }
          else{
            tagMap[index] = snapshot.value['name'];
          }
        });
      }
    }); 
    //Map to List
    tags = [];
    for (var i = 0; i < tags_cnt; i++) {
      tags.add(tagMap[i+1]);
    }
  }
  
  Future<void> loadsavedEvent() async{
    DbManager manager = DbManager();
    savedEvents = await manager.loadSavedEvents();
  }

  Future<void> loadEventsFromDatabase() async{
    //Get LastEventId
    await lastEventIdRef.once().then((firebase_datebase.DataSnapshot snapshot) async{
      lastEventId = snapshot.value['id'];
      // Load Events from Firebase
      events.clear();
      int count = lastEventId;
      eventsMap = {};
      for (var i = 0; i < count; i++) {
        int index = i+1;
         await downloadEvent(index);
      }
      //Map to List
      setState(() {
        events = [];
        for (var i = 0; i < count; i++) {
          events.add(eventsMap[i+1]);
        }
      });
     
    });
  }

  Future<Event> downloadEvent(int id) async{
    String title;
    String venue;
    DateTime date;
    List<int> event_fees = [];
    List<String> event_tags = [];
    int feesCnt;
    int tagsCnt;
    String contact;
    int ranking;

    await eventsRef.child('$id').once().then((firebase_datebase.DataSnapshot snapshot) async{
      if(snapshot.value == null){
        eventsMap[id] = null;
      }
      else{
        title = snapshot.value['title'];
        venue = snapshot.value['venue'];
        ranking = snapshot.value['ranking'];
        contact = snapshot.value['contact'];

        await eventsRef.child('$id').child('feesCnt').once().then((firebase_datebase.DataSnapshot snapshot) async{
          feesCnt = snapshot.value['count'];

          await eventsRef.child('$id').child('date').once().then((firebase_datebase.DataSnapshot snapshot) async{
            date = DateTime(snapshot.value['year'], snapshot.value['month'], snapshot.value['day'], snapshot.value['hour'], snapshot.value['minute'],);
            
            await eventsRef.child('$id').child('fees').once().then((firebase_datebase.DataSnapshot snapshot) async{
              for (var i = 0; i < feesCnt; i++) {
                int fee = snapshot.value[i];
                event_fees.add(fee);
              }

              await eventsRef.child('$id').child('tagsCnt').once().then((firebase_datebase.DataSnapshot snapshot) async{
                tagsCnt = snapshot.value['count'];

                await eventsRef.child('$id').child('tags').once().then((firebase_datebase.DataSnapshot snapshot) async{
                  for (var i = 0; i < tagsCnt; i++) {
                    int tag_id = snapshot.value[i];
                    String tag = getTagById(tag_id);
                    event_tags.add(tag);
                  }
                  
                  await loadEventImage(id,title,venue,date,event_fees,event_tags,contact,ranking);
                });

              });
            });
          });
        });
      }
    });
  }

  String getTagById(int id){
    tags.forEach((tag){

    });
    return tags[id-1];
  }

  Future<void> loadEventImage(int id, String title, String venue, DateTime date, List<int> fees, List<String> tags, String contact, int ranking) async{
    final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('event$id.jpg');
      await firebaseStorageRef.getDownloadURL().then<String>((dynamic firebase_url){   
        Event event =  Event(
          id: id, 
          title: title,
          venue: venue,
          date: date,
          fees: fees,
          tags: tags,
          contact: contact,
          ranking: ranking,
          imageUrl: firebase_url
        );
        eventsMap[id] = event;
      
      });
  }

  Map<DateTime, List<dynamic>> eventsListToMap(){
    eventsDateMap.clear();
    setState(() {
      events.forEach((e){
        if(e == null){
          e = Event(
            id: -5, 
            title: "null",
            date: DateTime(2020)
          );
        }

        if(eventsDateMap.containsKey(e.date)){
          eventsDateMap[e.date].add(e);
        }
        else{
          eventsDateMap[e.date] = new List<Event>();
          eventsDateMap[e.date].add(e);
        }
      });
      return eventsDateMap;
    });
  }


  String feesToString(List<int> list){
    String fees = '';
    list.forEach((v){
      fees = fees + 'N$v'+ ',  ' ;
    });
    return fees;
  }

  _launchCall() async {
    const url = 'tel://$lagos_events_contact_number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  void initState(){
    super.initState();
      loadTags().then((onValue){
        loadEventsFromDatabase().then((onValue){
          loadsavedEvent().then((onValue){

            //Fliter Events for Featured Events and Approved Events
            print("Raw Event Length: ${events.length}");
            List<Event> temp_events = [];
            //List<Event> temp_featured_events = [];
            int i = 0;
            events.forEach((element) {
              print("checking event : $i");
              if (element == null) {
                print("skipping null event: $i");
              } else {
                print("event ranking: ${element.ranking}");
                  if(element.ranking < 0){
                    print("skipping event not approved: $i");
                  }else{
                    print("adding event : $i");
                    temp_events.add(element);
                  }
              }
              i++;
            });
            events = List.from(temp_events);
            //End of Fliter Events for Featured Events and Approved Events

            eventsListToMap();

            events_master = events;
          });
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            image:  DecorationImage(
              image: AssetImage('assets/images/Moonlit_Asteroid.jpg'),
              fit: BoxFit.cover
            )
          ),
        ),

        tabController = DefaultTabController(
          length: 3,
          child: Scaffold(
            //resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.transparent,
            floatingActionButton: Container(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(),
                child: Icon(Icons.file_upload, size: 20, color: Color.fromRGBO(89, 234, 193, 1.0)),
                backgroundColor: Color.fromRGBO(207, 195, 226, 0.3),
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => UploadPage(
                      tags: tags, 
                      lastEventId: lastEventId, 
                      onUploaded: (lastId){
                        setState(() {
                          lastEventId = lastId;
                          //Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        });
                      })
                  ));
                }
              ),
            ),
            appBar: AppBar(
              centerTitle: true,
              iconTheme: new IconThemeData(color: purpleTint50),
              backgroundColor: Colors.transparent,
              //bottomOpacity: 1,
              elevation: 0.0,
              title: Column(
                children: <Widget>[
                  Padding(
                    child: Text(title, style: titleStyle),
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  ),
                ],
              ),
              bottom: PreferredSize(
                child: Column(
                  children: <Widget>[
                    Divider(color: greenAccent),
                    TabBar(
                      labelColor: purpleTint,
                      indicatorColor: greenAccent,
                      tabs: <Widget>[
                        Tab(
                          text: 'Events',
                        ),
                        Tab(
                          text: 'Calendar',
                        ),
                        Tab(
                          text: 'My Events',
                        ),
                      ],
                    ),
                  ],
                ),
                preferredSize: Size.fromHeight(size.height*0.09),
              ),
              
            ),
            drawer: Theme(
              data: Theme.of(context).copyWith(
                // Set the transparency here
                canvasColor: Colors.black.withOpacity(0.6),
              ),
              child : SizedBox( width: size.width*0.7, child: Drawer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(child: Padding(
                      child: Text('Lagos Events', style: TextStyle(color: Colors.grey, fontSize: 40, fontFamily: 'Sacramento')),
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    )),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
                      child: InkWell(
                        child:  Row(
                          children: <Widget>[
                            Icon(Icons.phone, size: 25, color: Colors.grey,),
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: OutlineButton(
                                child: Text('Contact Us', style: TextStyle(color: Colors.grey, fontSize: 18),),
                                onPressed: (){

                                },
                                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                color: Colors.grey,
                              )
                            )
                          ],
                        ),
                        onTap: (){
                          _launchCall();
                        },
                      ),
                    ),

                    Divider(color: Colors.grey,),
                    Divider(color: Colors.transparent,),
                    Container(
                      padding: EdgeInsets.all(25),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.autorenew, color: Colors.grey,),
                            Text('Refresh Events', style: drawerStyle),
                          ],
                        ),
                        onTap: (){
                          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        },
                      )
                    ),
                    Divider(color: Colors.transparent,),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('Communication',  style: drawerStyleH3,),
                    ),
                    Container(
                      padding: EdgeInsets.all(25),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.lock_outline, color: Colors.grey,),
                            Text('Privacy Policy', style: drawerStyle),
                          ],
                        ),
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute<Widget>(
                            builder: (BuildContext context) =>PrivacyPolicyPage()
                          ));
                        },
                      )
                    ),
                    Container(
                      padding: EdgeInsets.all(25),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.select_all, color: Colors.grey,),
                            Text('About App', style: drawerStyle),
                          ],
                        ),
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute<Widget>(
                            builder: (BuildContext context) =>AboutAppPage()
                          ));
                        },
                      )
                    ),

                  ]
                ),
              )),
            ),
            body: TabBarView(
              children: <Widget>[


                //Screen 1 
                events.isEmpty?
                Center (child: Container(
                  width: size.width*0.5,
                  height: size.width*0.5,
                  child: Stack(
                    children: <Widget>[
                      Center( child:Image.asset(
                        'assets/images/logo.png',
                        color: Color.fromRGBO(225, 225, 225, 0.2),
                        colorBlendMode: BlendMode.modulate,
                        fit: BoxFit.fill,
                      )),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ),
                )):
                EventsPage(
                  size: size,
                  events: events,
                  tags: tags,
                ),


                //Screen 2
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SingleChildScrollView(child: Column(
                    children: <Widget>[
                      Container(
                        child: TableCalendar(
                          events: eventsDateMap,
                          calendarController: _controller,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            centerHeaderTitle: true,
                            titleTextStyle: TextStyle(
                              color: Colors.grey
                            )
                          ),
                          calendarStyle: CalendarStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.grey
                            ),
                            markersColor: Colors.grey
                            
                          ),
                          onDaySelected: (dateTime, list, list2){
                            setState(() {
                              currentEvents.clear();
                              events.forEach((e){
                                //dateTime
                                if(e != null){
                                  if(dateTime.year == e.date.year && dateTime.month == e.date.month && dateTime.day == e.date.day){
                                    currentEvents.add(e);
                                  }
                                }
                                
                              });
                              
                            }); 
                          },

                          // onDaySelected: (dateTime, list){
                          //   setState(() {
                          //     currentEvents.clear();
                          //     events.forEach((e){
                          //       //dateTime
                          //       if(e != null){
                          //         if(dateTime.year == e.date.year && dateTime.month == e.date.month && dateTime.day == e.date.day){
                          //           currentEvents.add(e);
                          //         }
                          //       }
                                
                          //     });
                              
                          //   });    
                          // },
                          
                        ),
                      ),

                      Divider(color: Colors.transparent),
                      Divider(color: Colors.transparent),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Events', 
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25
                          ),
                        )
                      ),
                      
                      Divider(
                        color: Color.fromRGBO(89, 234, 193, 1.0),
                        //height: 15.0,
                        thickness: 2.0,
                      ),
                      Divider(color: Colors.transparent),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: currentEvents.length,
                          itemBuilder: (BuildContext context, int index) {
                            String feeList = feesToString(currentEvents[index].fees);
                            return Column(children: <Widget>[
                              InkWell(
                               onTap: (){
                                 Navigator.of(context).push(MaterialPageRoute<Widget>(
                                  builder: (BuildContext context) =>EventsEventPage(
                                    size: size,
                                    event: currentEvents[index],
                                  )
                                ));
                               },
                               child : Container(
                                height: size.height*0.12,
                                width: size.width*0.9,
                                color: Color.fromRGBO(19, 58, 68, 1), 
                                child: Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: size.width*0.28
                                      ),
                                      child: Image.network(currentEvents[index].imageUrl),//
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(10,10,0,0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(currentEvents[index].title, style: eventDetailsStyleH1),
                                          Row(
                                            children: <Widget>[
                                              Text('Venue - ',  style: eventDetailsStyle),
                                              Container(width: size.width*0.3, child: Text('${currentEvents[index].venue}', style: eventDetailsStyle))
                                            ],       
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text('Gate Fee - ',  style: eventDetailsStyle),
                                              Container(width: size.width*0.3, child: Text('${feeList}', style: eventDetailsStyle))
                                            ],       
                                          ),
                                        ],
                                      ),

                                  ),
                                  
                                ],),
                              )),
                              Divider(color: Colors.transparent,)
                            ],);
                          },
                      ),
                    ],
                  )),
                  
                ),
                
                //Screen3
                events.isEmpty?
                Center (child: Container(
                  width: size.width*0.5,
                  height: size.width*0.5,
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo.png',
                        color: Color.fromRGBO(225, 225, 225, 0.2),
                        colorBlendMode: BlendMode.modulate,
                        fit: BoxFit.fill,
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ),
                )):
                SavedEventsPage(events: events, size: size),
              ],
            ),
        ),
        )
        
      ],
    );

  }
}