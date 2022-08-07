import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/reminder.dart';

class RemindersPage extends StatefulWidget {
  Size size;
  Event event;
  final Function(List<Reminder>) onReminderUpdated;

  RemindersPage({this.size, this.event, this.onReminderUpdated});

  @override
  _RemindersPageState createState() => _RemindersPageState(size: size, event: event, onReminderUpdated: onReminderUpdated);
}

class _RemindersPageState extends State<RemindersPage> {

  Size size;
  Event event;
  DbManager dbManager = DbManager();
  List<Reminder> reminders = [];

  final  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  final Function(List<Reminder>) onReminderUpdated;

  _RemindersPageState ({this.size, this.event, this.onReminderUpdated});


  //***                Notification Utility function                    ***/

  Future onSelectNotification(String payload) async {
    
  }  

  NotificationDetails get _ongoing {
    final androidChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'youe channel description',
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
      autoCancel: true
    );

    final iOSChannelSpecifics = IOSNotificationDetails();

    return NotificationDetails(androidChannelSpecifics,iOSChannelSpecifics);

  }


  Future _showNotification(
    FlutterLocalNotificationsPlugin notification,
    {
      @required String title,
      @required String body,
      @required NotificationDetails type,
      @required int id,
      @required DateTime date,
    }
  ) => notification.schedule(
      id, 
      title,
      body, 
      date,
      _platformChannelSpecifics()
    );

  Future showOngoingNotification(
    FlutterLocalNotificationsPlugin notification,
    { 
      @required String title,
      @required String body,
      @required int id,
      @required DateTime date
    }
  ) => _showNotification(notification, title: title, body: body, id: id, type: _ongoing, date: date);

  NotificationDetails _platformChannelSpecifics(){
    var androidPlatformChannelSpecifics =
    new AndroidNotificationDetails(
      'your other channel id',
      'your other channel name', 
      'your other channel description'
    );
    var iOSPlatformChannelSpecifics =  new IOSNotificationDetails();
    
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics
    );

    return platformChannelSpecifics;
  }





 //***                Reminder Utility function                    ***/


  void loadReminders() async{
    DbManager dbManager =DbManager();
    //dbManager.clearReminders();
    reminders = await dbManager.loadReminders().then((onValue){
      setState(() {
        reminders = onValue;
      });
      return onValue;
    });
    
  }

  void setReminderNotification( int id, DateTime date){
    showOngoingNotification(flutterLocalNotificationsPlugin, title: 'Title', body: 'Body', id: id, date: date);
  }

  int generateAlertId(){
    int number = Random().nextInt(100);
    while (isAlertIdTaken(number)){
      number = Random().nextInt(200);
    }
    return number;
  }

  bool isAlertIdTaken(int number){
    bool b = false;
    reminders.forEach((r){
      if(r.alertId == number){
        b = true;
      }
    });
    return b;
  }

  void addReminder(String reminder, Event event){
    //Set Reminder using Api
    //Get Reminder Id
    DbManager dbManager = DbManager();
    int notificationId = generateAlertId();
    DateTime notificationDate;

    if(event.date.isBefore(DateTime.now())){
      return;
    }

    switch (reminder) {
      case '1 Hour Before' :{
        Reminder rem = makeReminder('1 Hour Before', notificationId,0,1);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
        //notificationDate = DateTime.now().add(Duration(seconds: 5));
      }break;
      case '2 Hour Before' :{
        Reminder rem = makeReminder('2 Hour Before', notificationId,0,2);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '3 Hour Before' :{
        Reminder rem = makeReminder('3 Hour Before', notificationId,0,3);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '1 Day Before' :{
        Reminder rem = makeReminder('1 Day Before', notificationId,1,0);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '2 Day Before' :{
        Reminder rem = makeReminder('2 Day Before', notificationId,2,0);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '3 Day Before' :{
        Reminder rem = makeReminder('3 Day Before', notificationId,3,0);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '1 Week Before' :{
        Reminder rem = makeReminder('1 Week Before', notificationId,7,0);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      case '2 Week Before' :{
        Reminder rem = makeReminder('2 Week Before', notificationId,14,0);
        reminders.add(rem);
        dbManager.addReminder(reminders, rem);
        notificationDate = DateTime(rem.alertTimeYear, rem.alertTimeMonth, rem.alertTimeDay, rem.alertTimeHour);
      }break;
      default:
    }
    
    setState(() {});

    setReminderNotification(notificationId, notificationDate);

    onReminderUpdated(reminders);
  }

  Future<void> removeReminderNotification(Reminder reminder) async{
    await flutterLocalNotificationsPlugin.cancel(reminder.alertId);
  }

  void removeReminder(String reminder, Event event){
    //Use notificationId to delete notification
    DbManager dbManager = DbManager();
    int index = 0;
    int cnt = 0;

    reminders.forEach((rem){
      if(rem.eventId==event.id && rem.name==reminder){
        index = cnt;
        dbManager.removeReminder(reminders, rem);
        removeReminderNotification(rem);
      }
      cnt++;
    });
    setState((){
      reminders.removeAt(index);
    });

    onReminderUpdated(reminders);
  }

  Reminder makeReminder(String reminder, int notificationId, int days, int hours){
    DateTime date = event.date.subtract(Duration(days: days )).subtract(Duration(hours: hours ));
     return Reminder(
          name: reminder,
          alertId: notificationId,
          eventId: event.id,
          alertTimeYear: date.year,
          alertTimeMonth: date.month,
          alertTimeDay: date.day,
          alertTimeHour: date.hour,
     );
  }


  @override
  void initState() { 
    loadReminders();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => onSelectNotification(payload)
    );

    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification
    );

    super.initState();
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
            title: Center(
              child: Column(
                children: <Widget>[
                  Text('LagosEvents',style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                ],
              ) 
            )
          ),
          body: Stack(
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
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 30),    
                    child: Wrap(
                      runSpacing: 5,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(event.title,textAlign: TextAlign.left, style: TextStyle(fontSize: 25, color: Color.fromRGBO(100, 100, 100, 1)),),
                        Divider(
                          color: Color.fromRGBO(89, 234, 193, 1.0),
                          height: 15.0,
                          thickness: 2.0,
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('1 Hour Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('1 Hour Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('1 Hour Before',event,reminders)){
                                removeReminder('1 Hour Before', event);
                              }else{
                                addReminder('1 Hour Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('2 Hour Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('2 Hour Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('2 Hour Before', event, reminders)){
                                removeReminder('2 Hour Before', event);
                              }else{
                                addReminder('2 Hour Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('3 Hour Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('3 Hour Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('3 Hour Before', event, reminders)){
                                removeReminder('3 Hour Before', event);
                              }else{
                                addReminder('3 Hour Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('1 Day Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('1 Day Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('1 Day Before', event,reminders)){
                                removeReminder('1 Day Before', event);
                              }else{
                                addReminder('1 Day Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('2 Day Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('2 Day Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('2 Day Before',event,reminders)){
                                removeReminder('2 Day Before', event);
                              }else{
                                addReminder('2 Day Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('3 Day Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('3 Day Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('3 Day Before', event,reminders)){
                                removeReminder('3 Day Before', event);
                              }else{
                                addReminder('3 Day Before', event);
                              } 
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('1 Week Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('1 Week Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('1 Week Before',event,reminders)){
                                removeReminder('1 Week Before', event);
                              }else{
                                addReminder('1 Week Before', event);
                              } 
                              //Navigator.of(context)
                            });
                          },
                        ),
                        RaisedButton(
                          color:dbManager.isReminderSet('2 Week Before', event, reminders)?
                                Color.fromRGBO(89, 234, 193, 0.3):
                                Color.fromRGBO(15, 57, 68, 1),
                          child: ListTile(
                            title: Text('2 Week Before'),
                          ),
                          onPressed: (){
                            setState(() {
                              if(dbManager.isReminderSet('2 Week Before', event,reminders)){
                                removeReminder('2 Week Before', event);
                              }else{
                                addReminder('2 Week Before', event);
                              } 
                            });
                          },
                        ),
                        FlatButton(
                          //elevation: 5,
                          color: Color.fromRGBO(72, 92, 99, 1),
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded( child:Text('Close', textAlign: TextAlign.center, style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300)))
                            ],    
                          )  
                        ),

                      ],
                    ),
                  )
                ],
              )
        ),
      ],
    );
  }
}