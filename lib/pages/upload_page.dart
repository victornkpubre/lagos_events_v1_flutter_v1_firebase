import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_database/firebase_database.dart' as firebase_datebase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lagos_events/dataBaseManager.dart';
import 'package:lagos_events/event.dart';


class UploadPage extends StatefulWidget {
  int lastEventId;
  List<String> tags;
  final Function(int) onUploaded;


  UploadPage({@required this.lastEventId, @required this.tags, @required this.onUploaded});

  @override
  _UploadPageState createState() => _UploadPageState(tags: tags, lastEventId:lastEventId, onUploaded: onUploaded);
  
}

class _UploadPageState extends State<UploadPage> {
  GlobalKey<AutoCompleteTextFieldState<String>> auto_completekey = new GlobalKey();

  final Function(int) onUploaded;

  List<Event> events = [];
  Map<int, Event> eventsMap = {};
  int lastEventId;
  Size size;
  List<int> fees = [];
  List<String> tags = [];
  List<String> selected_tags = [];
  File selectedImage;
  AutoCompleteTextField<String> autoTextField;
  TextEditingController contactController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController venueController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController yrController = TextEditingController();
  TextEditingController moController = TextEditingController();
  TextEditingController dyController = TextEditingController();
  TextEditingController hrController = TextEditingController();
  TextEditingController miController = TextEditingController();


  //Create Ref if it doesn't exist
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

  TextStyle submitStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'Rush Hour',
    fontWeight: FontWeight.bold,
    fontSize: 25,
  );

  TextStyle submitStyle2 = TextStyle(
    color: Colors.grey,
    fontFamily: 'Rush Hour',
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  DbManager dbManager = DbManager();
  List<int> uploadedEvents = [];


  _UploadPageState({@required this.lastEventId, @required this.tags, @required this.onUploaded});


  
  //***     Upload Functions    ****//

  void uploadEventDetails(){
    int id = lastEventId; 
    String title = titleController.text;
    String venue = venueController.text;
    String contact = contactController.text;

    eventsRef.child('$id').set({
      'id' : id,
      'title' : title,
      'venue' : venue,
      'ranking' : -5,
      'contact' : contact,
    });

    eventsRef.child('$id').child('date').set({
      'year' : int.parse(yrController.text),
      'month' : int.parse(moController.text),
      'day' : int.parse(dyController.text),
      'hour' : int.parse(hrController.text),
      'minute' : int.parse(miController.text),
    });

    Map<String, int> feeMap = {};
    for (var i = 0; i < fees.length; i++) {
      feeMap['$i'] = fees[i];
    }
    eventsRef.child('$id').child('fees').set(feeMap);

    eventsRef.child('$id').child('feesCnt').set({
      'count' : fees.length,
    });

    Map<String, int> tagMap = {};
    for (var i = 0; i < selected_tags.length; i++) {
      tagMap['$i'] = getTagId(selected_tags[i]);
    }
    eventsRef.child('$id').child('tags').set(tagMap);

    eventsRef.child('$id').child('tagsCnt').set({
      'count' : selected_tags.length,
    });

  }

  int getTagId(String tag){
    if(tags.contains(tag)){
      
    }else{
      addTagtoMasterList(tag);
    }
    return tags.indexOf(tag);
  }

  void addTagtoMasterList(String tag){
    tags.add(tag);
    tagsRef.child('${tags.length}').set({
      'name' : tag
    });
    lastTagIdRef.set({'id' : tags.length});
    
  }

  void uploadEventImage(int id) async{
    String imageName = 'event'+'$id.jpg';
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(imageName);
    firebaseStorageRef.putFile(selectedImage);
  }

  void submit(){
    lastEventId = lastEventId + 1;
    setLastId(lastEventId);
    //showMessageSubmittedDialog();
    if(validateForm()){
      uploadEventImage(lastEventId);
      uploadEventDetails();
      saveUploadedEvent(lastEventId);
      showMessageAlertDialog('Event Submited');
      setState(() {
        clearForm();
      });
    }
    
  }

  void clearForm(){
    titleController.clear();
    venueController.clear();
    contactController.clear();
    clearDate();
    fees = [];
    selected_tags = [];
    selectedImage = null;
  }

  void showMessageAlertDialog(String message ){
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context){
        return SizedBox(
          child: AlertDialog(
            content: Center( child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(message),
                Divider(color: Colors.transparent),
              ], 
            )),
          ),
        );
      }
    );
  }

  void showMessageSubmittedDialog(){
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context){
        return SizedBox(
          child: AlertDialog(
            content: Center( child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Event has been Submitted', style: submitStyle,),
                Divider(color: Colors.transparent),
                Text('Go to the Side Menu and Refresh the Events', style: submitStyle2, textAlign: TextAlign.center,),
                Container(
                  width: size.width*0.4,
                  child: Image.asset('assets/images/refresh.png'),
                ),
                

              ], 
            )),
          ),
        );
      }
    );
  }

  bool validateForm(){
    if( fees.isNotEmpty || feeController.value != null){
      if(titleController.text != null){
        if(venueController.text != null){
          //Date Verification
          if(yrController.text != null && int.parse(yrController.text.toString()) > 2019){
            if(moController.text != null && int.parse(moController.text.toString()) > 0 && int.parse(moController.text.toString()) <= 12){
              if(dyController.text != null && int.parse(dyController.text.toString()) > 0 && int.parse(moController.text.toString()) <= 31){
                if(hrController.text != null && int.parse(hrController.text.toString()) > 0 && int.parse(hrController.text.toString()) <= 24 ){
                  if(miController.text != null && int.parse(miController.text.toString()) >= 0 && int.parse(miController.text.toString()) < 60){

                    if( selectedImage != null){
                      
                      return true;
                    }else{
                      showMessageAlertDialog('Enter Event Image');
                      return false;
                    }

                  }else{//mi
                    showMessageAlertDialog('Enter Minutes');
                    return false;
                  }
                }else{//hr
                  showMessageAlertDialog('Enter Hour of the Day');
                  return false;
                }
              }else{//dy
                showMessageAlertDialog('Enter Day of the Month');
                return false;
              }
            }else{//mo
              showMessageAlertDialog('Enter Month of Event');
              return false;
            }
          }else{//yr
            showMessageAlertDialog('Enter the Year');
            return false;
          }


        }else{//venue
          showMessageAlertDialog('Enter Event Venue');
          return false;
        }
      }else{//title
        showMessageAlertDialog('Enter Event Title');
        return false;
      }
    }else{//fees
      showMessageAlertDialog('Enter Atleast one Gate Fee');  
      return false;
    }
  }


  //***   Object Functions   ***//
  void addGateFee(int fee){
    setState(() {
      fees.add(fee);
    });
    
  }
  void deleteGateFee(int fee){
    setState(() {
      fees.remove(fee);
    });
    
  }

  void addTag(String tag){
    setState(() {
      selected_tags.add(tag);
    });
    
  }
  void deleteTag(String tag){
    setState(() {
      selected_tags.remove(tag);
    });
    
  }

  void clearDate(){
    yrController.clear();
    moController.clear();
    dyController.clear();
    hrController.clear();
    miController.clear();
  }

  void chooseImage() async{
    var tempImage = await ImagePicker.pickImage(
      source: ImageSource.gallery
    );
    setState(() {
      selectedImage = tempImage;
    });
  }

  //Uploaded Events Functions
  void loadSavedEvents() async{
    uploadedEvents = await dbManager.loadUploadedEvents();
    setState(() {
      
    });
  }

  void unsaveUploadedEvent(int event_id) async{
    uploadedEvents = await dbManager.removeUploadedEvent(event_id);
  }

  void saveUploadedEvent(int event_id) async{
    uploadedEvents = await dbManager.addUploadedEvent(event_id);
  }



  //***   Event Id Function   ***//
  void setLastId(int id){
    lastEventIdRef.set({'id' : id});
  }

  //***   Init Function   ***//
  @override
  void initState() {
    super.initState();
    
  }


  //***  UI function  ***//
  Widget getListOfFees(){
    return Container(
      width: size.width*0.8,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fees.length,
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              deleteGateFee(fees[index]);
            },
            child: Text(
              'N${fees[index]}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getListOfTags(){
    return Container(
      width: size.width*0.8,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selected_tags.length,
        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: (){
              deleteTag(selected_tags[index]);
            },
            child: Text(
              '#${selected_tags[index]}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey
              ),
            ),
          );
        },
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Stack( children: <Widget>[
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
          iconTheme: IconThemeData(
            color: purpleTint50, //change your color here
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text('Upload Event', style: titleStyle),
        ),
        body: SingleChildScrollView( child: Center(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    child: selectedImage == null?
                      InkWell(
                        child: Icon(Icons.image, size: 150, color: Colors.grey,),
                        onTap: (){
                          chooseImage();
                        },
                      ):
                      Container(
                        width: size.width*0.7,
                        child: Image.file(selectedImage),
                      )
                  ),
                  RaisedButton(
                    elevation: 5,
                    color: Color.fromRGBO(72, 92, 99, 1),
                    onPressed: (){
                      chooseImage();
                    },
                    child: Text('Choose Event Image', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1)),),
                  ),
                ],
              ),

              Container(
                width: size.width*0.8,
                child: TextField(
                  controller: titleController,
                  style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                  decoration: InputDecoration(
                    hintText: 'Event Title',
                    hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),                  
                  ),
                ), 
              ),

              Container(
                width: size.width*0.8,
                child: TextField(
                  controller: venueController,
                  style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                  decoration: InputDecoration(
                    hintText: 'Event Venue',
                    hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                  ),
                ), 
              ),

              //List of Tags
              Container(
                child : selected_tags == null?
                Divider(color: Colors.transparent):
                getListOfTags(),
              ),

              Container(
                width: size.width*0.8,
                child : Row(
                  children: <Widget>[
                    Container(
                      width: size.width*0.4,
                      child: autoTextField = AutoCompleteTextField<String>(
                        clearOnSubmit: false,
                        style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                        decoration: InputDecoration(
                          hintText: 'Enter Tag',
                          hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                        ), 
                        key: auto_completekey,
                        suggestions: tags, 
                        itemFilter: (item, query) { 
                          return item.toLowerCase().startsWith(query.toLowerCase());
                        },
                        itemBuilder: (context, string){
                          return Container(
                            padding: EdgeInsets.fromLTRB(10,5,10,5),
                            color: Colors.transparent,
                            child: Text(string, style: TextStyle(color: Colors.grey)),
                          );
                        }, 
                        itemSorter: (String a, String b){
                          return a.compareTo(b);
                        }, 
                        itemSubmitted: (item){
                         setState((){
                            autoTextField.textField.controller.text = item.toLowerCase();                        
                          });
                        },
                      ),
                    ),

                    Container(
                      width: size.width*0.4,
                      child: RaisedButton(
                        elevation: 5,
                        color: Color.fromRGBO(72, 92, 99, 1),
                        onPressed: (){
                          if(autoTextField.textField.controller.text != null){
                            setState(() {
                              if(autoTextField.textField.controller.text != ""){
                                addTag(autoTextField.textField.controller.text);
                                autoTextField.clear();
                                autoTextField.textField.controller.clear();
                              }
                            });
                          }     
                        },
                        child: Text('Add Tag', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                      ),
                    ),      
                  ],
                ),
              ),



              //List of Fees
              Container(
                child : fees == null?
                Divider(color: Colors.transparent):
                getListOfFees(),
              ),


              Container(
                width: size.width*0.8,
                child : Row(
                  children: <Widget>[
                    Container(
                      width: size.width*0.4,
                      child: TextField(
                        controller: feeController,
                        style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1)),
                        decoration: InputDecoration(
                          hintText: 'Enter Gate Fee',
                          hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                        ),
                        keyboardType: TextInputType.number,
                      ), 
                    ),

                    Container(
                      width: size.width*0.4,
                      child: RaisedButton(
                        elevation: 5,
                        color: Color.fromRGBO(72, 92, 99, 1),
                        onPressed: (){
                          if(feeController.value.text != ""){
                            setState(() {
                              addGateFee(int.tryParse(feeController.text.toString()));
                              feeController.clear();
                            });
                          }     
                        },
                        child: Text('Add Gate Fee', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                      ),
                    ),      
                  ],
                ),
              ),

              Container(
                width: size.width*0.8,
                child: TextField(
                  controller: contactController,
                  style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                  decoration: InputDecoration(
                    hintText: 'Enter Contact Number',
                    hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),                  
                  ),
                  keyboardType: TextInputType.number,
                ), 
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 25, 0),
                    child: Text('Event Date', style: TextStyle(fontSize: 20, color: Color.fromRGBO(207, 195, 226, 1))),
                  ),
                  Container(
                    width: size.width*0.5,
                    
                    child: Center( child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: size.width*0.1,
                          child: TextField(
                            controller: yrController,
                            style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                            decoration: InputDecoration(
                              hintText: 'Yr',
                              hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: size.width*0.1,
                          child: TextField(
                            controller: moController,
                            style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                            decoration: InputDecoration(
                              hintText: 'Mo',
                              hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: size.width*0.1,
                          child: TextField(
                            controller: dyController,
                            style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                            decoration: InputDecoration(
                              hintText: 'Dy',
                              hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: size.width*0.1,
                          child: TextField(
                            controller: hrController,
                            style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                            decoration: InputDecoration(
                              hintText: 'Hr',
                              hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: size.width*0.1,
                          child: TextField(
                            controller: miController,
                            style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                            decoration: InputDecoration(
                              hintText: 'Mi',
                              hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                            ),
                            keyboardType: TextInputType.number,
                          )
                        ),
                        

                      ],
                    )),
                  ),
                ],
              ),
              Container( width: size.width*0.8, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded( child: RaisedButton(
                    elevation: 5,
                    color: Color.fromRGBO(72, 92, 99, 1),
                    onPressed: () {
                      showDatePicker(
                        context: context, 
                        initialDate: DateTime.now(), 
                        firstDate: DateTime.now().subtract(Duration(days: 1)), 
                        lastDate: DateTime.now().add(Duration(days: 365)),       
                      ).then((datetime) {
                        yrController.text = '${datetime.year}';
                        moController.text = '${datetime.month}';
                        dyController.text = '${datetime.day}';
                        hrController.text = '${datetime.hour}';
                        miController.text = '${datetime.minute}';
                      });
                    },
                    child: Text('Pick Date', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                  )),
                  Expanded( child: RaisedButton(
                    elevation: 5,
                    color: Color.fromRGBO(72, 92, 99, 1),
                    onPressed: () {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((time) {
                        hrController.text = '${time.hour}';
                        miController.text = '${time.minute}';
                      });
                    },
                    child: Text('Pick Time', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                  )),
                ],
              )),

              Divider(color: Colors.transparent),

              SizedBox(
                width: size.width*0.8,
                child: RaisedButton(
                  elevation: 5,
                  color: Color.fromRGBO(72, 92, 99, 1),
                  onPressed: (){
                    submit();
                    onUploaded(lastEventId);
                  },
                  child: Text('Submit Event', style: TextStyle(color: Color.fromRGBO(207, 195, 226, 1))),
                )
              ),

              Divider(color: Colors.transparent),
              
            ],
          ),
        ))
      )
    ],);
  }
}