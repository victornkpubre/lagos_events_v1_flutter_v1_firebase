import 'package:flutter/material.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/reminder.dart';

class EventsEventPage extends StatefulWidget {
  Size size;
  Event event;

  EventsEventPage({this.size, this.event});

  @override
  _EventsEventPageState createState() => _EventsEventPageState(size: size, event: event);
}

class _EventsEventPageState extends State<EventsEventPage> {

  Size size;
  Event event;
  DbManager dbManager = DbManager();
  List<int> savedEvents = [];

  TextStyle titleStyle = TextStyle(
    color: Color.fromRGBO(194, 174, 225, 1),
    fontFamily: 'Sacramento',
    fontWeight: FontWeight.w500,
    fontSize: 30,
  );

  _EventsEventPageState ({this.size, this.event});

  String feeToString(Event event){
    String feeStr = '';
    event.fees.forEach((r){
      feeStr = feeStr + 'N$r'+ ',  ' ;
    });
    return feeStr;
  }

  String dateToString(Event event){
    return '${event.date.year}-${event.date.month}-${event.date.day}';
  }

  void loadSavedEvents() async{
    savedEvents = await dbManager.loadSavedEvents();
    setState(() {
      
    });
  }

  void unSaveEvent(Event event) async{
    savedEvents = await dbManager.removeSavedEvent(event);
  }

  void saveEvent(Event event) async{
    savedEvents = await dbManager.addSavedEvent(event);
  }

  @override
  void initState() {
    super.initState();
    loadSavedEvents();
    
  }

  @override
  Widget build(BuildContext context) {
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            title: Column(
                children: <Widget>[
                  Text('LagosEvents',style: titleStyle),
                ],
              ) 
          ),
          body: SingleChildScrollView(child: Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              child: Column( 
                children: <Widget>[
                  Container(
                    width: size.width*0.6,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child:  Image.network(event.imageUrl, fit: BoxFit.fill,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child:  Text(event.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color.fromRGBO(100, 100, 100, 1)),),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child:  Text(event.venue, style: TextStyle(color: Color.fromRGBO(100, 100, 100, 1))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child:  Text(dateToString(event), style: TextStyle(color: Color.fromRGBO(100, 100, 100, 1))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child:  Text(feeToString(event), style: TextStyle(color: Color.fromRGBO(100, 100, 100, 1))),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: RaisedButton(
                      elevation: 5,
                      color: Color.fromRGBO(72, 92, 99, 1),
                      onPressed: (){
                        setState(() {
                          if(dbManager.isSavedEvent(event, savedEvents)){
                            unSaveEvent(event);
                          }
                          else{
                            saveEvent(event);
                          }
                        });     
                      },
                        child: Row(
                          children: <Widget>[
                            Expanded( child: Icon(
                              Icons.check_box, 
                              color: (dbManager.isSavedEvent(event, savedEvents))?
                                      Color.fromRGBO(89, 234, 193, 1.0):
                                      Color.fromRGBO(65, 65, 65, 1),
                            )),
                            Expanded( 
                              child: Text('Save Event', textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w300))
                            ),
                          ],
                        )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: RaisedButton(
                      elevation: 5,
                      color: Color.fromRGBO(72, 92, 99, 1),
                      onPressed: (){Navigator.pop(context);},
                      child: Row(
                        children: <Widget>[
                          Expanded( child:Text('Close', textAlign: TextAlign.center, style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300)))
                        ],    
                      )  
                    )
                  ),                                 
                ],
              ),
            )
          )),
        ),
      ],
    );
  }
}