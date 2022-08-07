import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:lagos_events/event.dart';
import 'package:lagos_events/pages/events_event_page.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;

class EventsPage extends StatefulWidget {
  final Size size;
  List<Event> events;
  List<String> tags;

  EventsPage({@required this.size, @required this.events, @required this.tags});

  @override
  _EventsPageState createState() => _EventsPageState(size: size, events: events, tags: tags);
}

class _EventsPageState extends State<EventsPage> {
  List<String> tags;
  final Size size;
  List<Event> events;
  List<Event> events_master;
   List<String> eventsTitles = [];

  GlobalKey<AutoCompleteTextFieldState<String>> search_auto_completekey = new GlobalKey();
  AutoCompleteTextField<String> search_autoTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> tags_auto_completekey = new GlobalKey();
  AutoCompleteTextField<String> tags_autoTextField;
  DateTime minDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime maxDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: 56));

  double minFee = 0;
  double maxFee = 100000;

  //State Vars
  bool filtering = false;
  bool sorting = false;
  String sortingState = 'None';
  String filteringState = 'None';
  String current_tag = null;
  bool searching = false;
  Icon search_icon = Icon(Icons.search, color: Colors.grey);
  

  //Date Enum
  List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  //Styles
  TextStyle eventDetailsStyle = TextStyle(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontFamily: 'poison',
    fontSize: 15
    
  );

  TextStyle eventDetailsStyleH1 = TextStyle(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontFamily: 'MontaseliSans',
    fontSize: 25
  );

  double filterTextSize;
  double sortTextSize;



  _EventsPageState({@required this.size, @required this.events, @required this.tags});

  void eventsListToEventTitles(){
    events.forEach((e){
      if(e != null){
        eventsTitles.add(e.title);
      }
    });
  }

  String _dateToMonthDay(DateTime date, String name){
    if(date == null){
      return name;
    }
    else{
       return '${months[date.month]} ${date.day}';
    }
  }

  void resetDateFilter(){
    setState(() {
      minDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      maxDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(Duration(days: 56));
    });
  }

  void resetFeeFilter(){
    setState(() {
      minFee = 0;
      maxFee = 100000;
    });
  }

  void resetTagFilter(){
    setState(() {
      filteringState = 'None';
      current_tag = null;
    });
  }

  String _feeToString(double fee, String name){
    if(fee == -1){
      return name;
    }
    else{
      int fee_int = fee.toInt();
      return 'N$fee_int';
    }
    
  }

  String feeToString(Event event){
    String feeStr = '';
    event.fees.forEach((r){
       if(r != null){
        feeStr = feeStr + 'N$r'+ ',  ' ;
       }
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
    return '${weekdays[event.date.weekday]}, ${event.date.day}th, ${months[event.date.month]} ${event.date.year}';
  }

  void sortEventsByDateUpward(){
    events.sort((a,b){
       if(a != null && b != null){
        return b.date.compareTo(a.date);
       }
    });
    sortingState = 'ByDateUp';
  }

  void sortEventsByDateDownward(){
    events.sort((a,b){
       if(a != null && b != null){
         return a.date.compareTo(b.date);
       }
    });
    sortingState = 'ByDateDown';
  }

  void sortEventsByFeeUpward(){
    events.sort((a,b){
       if(a != null && b != null){
        return b.fees[0].compareTo(a.fees[0]); // compare using lowest fee
       }
    });
    sortingState = 'ByFeeUp';
  }

  void sortEventsByFeeDownward(){
    events.sort((a,b){
      if(a != null && b != null){
        return a.fees[0].compareTo(b.fees[0]); // compare using lowest fee
      }
    });
    sortingState = 'ByFeeDown';
  }

  void filterEventsByDate(DateTime min, DateTime max){
    List<Event> temp = [];
    events_master.forEach((e){
      if(e != null){
        if(e.date.compareTo(min)>=0 && e.date.compareTo(max)<=0){
          temp.add(e);
        }
      }
    });

    events = temp;

    switch (sortingState) {
      case 'ByFeeUp':{
        sortEventsByFeeUpward();
      }break;
      case 'ByDateUp':{
        sortEventsByDateUpward();
      }break;
      case 'ByFeeDown':{
        sortEventsByFeeDownward();
      }break;
      case 'ByDateDown':{
        sortEventsByDateDownward();
      }break;
      case 'None':{
      }break;
      default:
    }
  }

  void filterEventsByFee(int min, int max){
    List<Event> temp = [];
    events_master.forEach((e){
      if(e != null){
        if(e.fees[0] >= min && e.fees[0] <= max){
          temp.add(e);
        }
      }
    });

    events = temp;

    switch (sortingState) {
      case 'ByFeeUp':{
        sortEventsByFeeUpward();
      }break;
      case 'ByDateUp':{
        sortEventsByDateUpward();
      }break;
      case 'ByFeeDown':{
        sortEventsByFeeDownward();
      }break;
      case 'ByDateDown':{
        sortEventsByDateDownward();
      }break;
      case 'None':{
      }break;
      default:
    }
  }

  void filterEventsByTag(){


  }

  void showDateRangePicker() async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: minDate,
      initialLastDate: maxDate,
      firstDate: new DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day),
      lastDate: new DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day)
    );
    if (picked != null && picked.length == 2) {
      setState(() {
        minDate = picked.first;
        maxDate = picked.last;
        filteringState = 'ByDate';
        filterEventsByDate(minDate, maxDate);
      });
    }
  }

  void showFeeRangePicker() async{
     final v = await showDialog<Widget>(
      context: context,
      builder: (context){
        return Dialog(
          child: Padding(padding: EdgeInsets.all(25), child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded( 
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Min', textAlign: TextAlign.start),
                    ),
                  ),
                  Expanded( 
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Max', textAlign: TextAlign.end),
                    ),
                  ),
                ],
              ),
              frs.RangeSlider(
                min: 0,
                max: 100000,
                showValueIndicator: true,
                valueIndicatorMaxDecimals: 0,
                lowerValue: minFee,
                upperValue: maxFee,
                divisions: 50, 
                onChanged: (double newLowerValue, double newUpperValue) {
                  setState((){
                    minFee = newLowerValue;
                    maxFee = newUpperValue;
                    filteringState = 'ByFee';
                    filterEventsByFee(minFee.toInt(), maxFee.toInt());
                  });
                },     
              )
            ],
          )),
        );
      }
    );
  }


  void displaySearchResult(String search_text){
    events = [];
    setState(() {
      events_master.forEach((e){
        if(e != null){
          if(e.title.toLowerCase().compareTo(search_text.toLowerCase()) == 0){
            events.add(e);
          }
        }
      }); 
    });
  }

  void displayTagSearchResult(String search_text){
    events = [];
    setState(() {
      events_master.forEach((e){
        if(e != null){
          for (var tag in e.tags) {
            if(tag.toLowerCase().compareTo(search_text.toLowerCase()) == 0){
              events.add(e);
              break;
            }
          }
        }
      }); 
    });
  }

  void closeSearchResult(){
    setState((){
      events = List.from( events_master); 
    });
  }



  @override
  void initState() {
    filterTextSize = size.width*0.030;
    sortTextSize = size.width*0.033;

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

    events_master = List.from(events);
    eventsListToEventTitles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            child: Column(              
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded( 
                        child: Container(
                          alignment: Alignment.bottomLeft, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container (
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                alignment: Alignment.topLeft, 
                                child: InkWell(
                                  onTap: (){
                                    setState((){
                                      if(sorting){
                                        sorting = false;
                                      }
                                      else{
                                        sorting = true;
                                      }
                                    });
                                  },
                                  child: Text('Sort', textAlign: TextAlign.end, style: TextStyle(fontSize: 14,color: Color.fromRGBO(207, 195, 226, 1)))
                                )
                              ),
                              Visibility(
                                visible: sorting,
                                child: Container ( 
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 7, 15, 0),
                                          child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: (){
                                                      setState(() {
                                                        if((sortingState.compareTo('ByDateUp')==0)){
                                                          sortEventsByDateDownward();
                                                        }
                                                        else{
                                                          sortEventsByDateUpward();
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      'By Date', 
                                                      style: TextStyle(
                                                        fontSize: sortTextSize, 
                                                        color: (sortingState.compareTo('ByDateUp')==0) || (sortingState.compareTo('ByDateDown')==0)? 
                                                        Color.fromRGBO(89, 234, 193, 1.0):
                                                        Color.fromRGBO(207, 195, 226, 1),
                                                      )
                                                    ),
                                                  ),
                                                  (sortingState.compareTo('ByDateUp')==0)?  
                                                  Icon(
                                                    Icons.arrow_upward,
                                                    size: 18,
                                                    color: (sortingState.compareTo('ByDateUp')==0) || (sortingState.compareTo('ByDateDown')==0)? 
                                                      Color.fromRGBO(89, 234, 193, 1.0):
                                                      Color.fromRGBO(207, 195, 226, 1),
                                                  ):
                                                  Icon(
                                                    Icons.arrow_downward,
                                                    size: 18,
                                                    color: (sortingState.compareTo('ByDateUp')==0) || (sortingState.compareTo('ByDateDown')==0)? 
                                                      Color.fromRGBO(89, 234, 193, 1.0):
                                                      Color.fromRGBO(207, 195, 226, 1),
                                                  ),
                                                  Visibility(
                                                    visible: sortingState.compareTo('ByDateUp')==0 || sortingState.compareTo('ByDateDown')==0,
                                                    child: Container(
                                                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                                      child: InkWell(
                                                        onTap: (){
                                                          setState(() {
                                                            events = List.from(events_master);
                                                            sortingState = 'None';
                                                          });
                                                        },
                                                        child: Icon(Icons.close, color: Colors.grey, size: 18,),
                                                      )
                                                    ),
                                                  )
                                                ],
                                              )
                                          )
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
                                          child: Container(
                                            child: Row(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: (){
                                                      setState(() {
                                                        if((sortingState.compareTo('ByFeeUp')==0)){
                                                          sortEventsByFeeDownward();
                                                        }
                                                        else{
                                                          sortEventsByFeeUpward();
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      'By Fee', 
                                                      style: TextStyle(
                                                        fontSize: sortTextSize, 
                                                        color: (sortingState.compareTo('ByFeeUp')==0) || (sortingState.compareTo('ByFeeDown')==0)? 
                                                        Color.fromRGBO(89, 234, 193, 1.0):
                                                        Color.fromRGBO(207, 195, 226, 1),
                                                      )
                                                    ),
                                                  ),
                                                  (sortingState.compareTo('ByFeeUp')==0)?  
                                                  Icon(
                                                    Icons.arrow_upward,
                                                    size: 18,
                                                    color: (sortingState.compareTo('ByFeeUp')==0) || (sortingState.compareTo('ByFeeDown')==0)? 
                                                      Color.fromRGBO(89, 234, 193, 1.0):
                                                      Color.fromRGBO(207, 195, 226, 1),
                                                  ):
                                                  Icon(
                                                    Icons.arrow_downward,
                                                    size: 18,
                                                    color: (sortingState.compareTo('ByFeeUp')==0) || (sortingState.compareTo('ByFeeDown')==0)? 
                                                      Color.fromRGBO(89, 234, 193, 1.0):
                                                      Color.fromRGBO(207, 195, 226, 1),
                                                  ),
                                                  Visibility(
                                                    visible: sortingState.compareTo('ByFeeUp')==0 || sortingState.compareTo('ByFeeDown')==0,
                                                    child: Container(
                                                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                                      child: InkWell(
                                                        onTap: (){
                                                          setState(() {
                                                            events = List.from(events_master);
                                                            sortingState = 'None';
                                                          });
                                                        },
                                                        child: Icon(Icons.close, color: Colors.grey, size: 18,),
                                                      )
                                                    ),
                                                  )
                                                ],
                                              )
                                          )
                                        ),
                                                                      
                                      ],
                                    ),
                                  )
                                ),
                              )
                            ],
                          )
                        )
                      ),
                      Expanded( 
                        child: Container(
                          alignment: Alignment.topRight, 
                          child: Column(
                            children: <Widget>[
                              Container (
                                padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                alignment: Alignment.topRight, 
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      if(filtering){
                                        filtering = false;
                                      }
                                      else{
                                        filtering = true;
                                      }
                                    });
                                  },
                                  child: Text('Filter', style: TextStyle(fontSize: 14,color: Color.fromRGBO(207, 195, 226, 1)))
                                )
                              ),
                              Visibility(
                                visible: filtering,
                                child: Container (
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0.0, 15.0, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: (){
                                            if(filteringState == 'ByDate'){
                                              filteringState = 'None';
                                              resetDateFilter();
                                              closeSearchResult();
                                            }else{
                                              resetFeeFilter();
                                              resetTagFilter();
                                              showDateRangePicker();
                                            }
                                          },

                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Visibility(
                                                visible: filteringState == 'ByDate',
                                                child: Icon(Icons.close, color: filteringState == 'ByDate'? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), size: 18,),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Date: '+_dateToMonthDay(minDate,'Min') +' - '+_dateToMonthDay(maxDate,'Max'), 
                                                  style: TextStyle(
                                                    fontSize: filterTextSize,
                                                    color: filteringState == 'ByDate'? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), 
                                                  )
                                                ),
                                              ),
                                            ],
                                          )
                                        ),
                                        InkWell(
                                          onTap: (){
                                            if(filteringState == 'ByFee'){
                                              filteringState = 'None';
                                              resetFeeFilter();
                                              closeSearchResult();
                                            }else{
                                              resetDateFilter();
                                              resetTagFilter();
                                              showFeeRangePicker();
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Visibility(
                                                visible: filteringState == 'ByFee',
                                                child: Icon(Icons.close, color:filteringState == 'ByFee'? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), size: 18,),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Gate Fee: '+_feeToString(minFee,'Min') +' - '+_feeToString(maxFee,'Max'), 
                                                  style: TextStyle(
                                                    fontSize: filterTextSize,
                                                    color: filteringState == 'ByFee'? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), 
                                                  )
                                                )
                                              )   
                                            ],
                                          ), 
                                        ), 
                                        InkWell(
                                          onTap: (){
                                            setState(() {
                                              if(filteringState != 'ByTag'){
                                                filteringState = 'ByTag';
                                                resetDateFilter();
                                                resetFeeFilter();
                                              }else{
                                                resetTagFilter();
                                                closeSearchResult();
                                              }
                                            });   
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Visibility(
                                                visible: current_tag != null,
                                                child: Icon(Icons.close, color: current_tag != null? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), size: 18,),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text(current_tag != null? 
                                                'Tag: '+current_tag : 
                                                'Tag: None', 
                                                  style: TextStyle(
                                                    fontSize: filterTextSize,
                                                    color: current_tag != null? Color.fromRGBO(89, 234, 193, 1.0) : Color.fromRGBO(207, 195, 226, 1), 
                                                  )
                                                )
                                              ),
                                            ],
                                          ) 
                                        ),                            
                                      ],
                                    ),
                                  )
                                ),
                              )      
                            ],
                          )
                        )
                      ),
                    ],
                  ),      
                ),      
                Stack(
                  children: <Widget>[
                    Positioned(
                      right: 10,
                      top: 10,
                      width: 50,
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            if(!searching){
                              filteringState ='None';
                              sortingState = 'None';
                              filtering = false;
                              sorting  = false;
                              searching = true;
                              search_icon =  Icon(Icons.close, color: Colors.grey,);
                            }else{
                              searching = false;
                              search_icon =  Icon(Icons.search, color: Colors.grey,);
                              closeSearchResult();
                              //clear search and reset events
                            }
                          });
                        },
                        icon: search_icon
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: filtering || sorting? size.height*0.6: size.height*0.7,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        children: <Widget>[
                          Divider(
                            color: Color.fromRGBO(89, 234, 193, 1.0),
                            height: 5.0,
                            thickness: 2.0,
                          ), 
                          Visibility(
                            visible: searching,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                              child: Container(
                                child: search_autoTextField = AutoCompleteTextField<String>(
                                  clearOnSubmit: false,
                                  style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                                  decoration: InputDecoration(
                                    hintText: 'search',
                                    hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                                  ), 
                                  key: search_auto_completekey,
                                  suggestions: eventsTitles, 
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
                                      search_autoTextField.textField.controller.text = item.toLowerCase(); 
                                      displaySearchResult(item.toLowerCase());                    
                                    });
                                  },
                                ),
                              ),  
                            )
                          ),
                          Visibility(
                            visible: filteringState == 'ByTag',
                            child: Container(
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                              child: Container(
                                child: tags_autoTextField = AutoCompleteTextField<String>(
                                  clearOnSubmit: false,
                                  style: TextStyle(color:Color.fromRGBO(207, 195, 226, 1),),
                                  decoration: InputDecoration(
                                    hintText: 'search by tags',
                                    hintStyle: TextStyle(color: Color.fromRGBO(207, 195, 226, 1), fontWeight: FontWeight.w200),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:  Color.fromRGBO(207, 195, 226, 1))),
                                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(207, 195, 226, 1))),
                                  ), 
                                  key: tags_auto_completekey,
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
                                      tags_autoTextField.textField.controller.text = item.toLowerCase();
                                      current_tag = item.toLowerCase();
                                      displayTagSearchResult(item.toLowerCase());                    
                                    });
                                  },
                                ),
                              ),  
                            )
                          ),
                          Expanded(
                            child: Container(
                            width: size.width*0.6,

                            //List of Events
                              child: ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index){
                                  if(events[index] == null){
                                    return Container();
                                  }else{
                                    return InkWell(
                                      onTap: (){
                                        Navigator.of(context).push(MaterialPageRoute<Widget>(
                                          builder: (BuildContext context) =>EventsEventPage(
                                            size: size,
                                            event: events[index],
                                          )
                                        ));
                                      },
                                      child : Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          GridTile(
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.bounceIn,
                                              placeholder: 'assets/images/loadinglogo.png',
                                              placeholderCacheHeight: 70,
                                              image: events[index].imageUrl,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          Divider(color: Colors.transparent,),
                                          Text(events[index].title,
                                            textAlign: TextAlign.center, 
                                            style: eventDetailsStyleH1
                                          ),
                                          Text(events[index].venue, textAlign: TextAlign.center, style: eventDetailsStyle,),
                                          Text(dateToString(events[index]), textAlign: TextAlign.center, style: eventDetailsStyle,),
                                          Text(feeToString(events[index]), textAlign: TextAlign.center, style: eventDetailsStyle,),
                                          Text('Contact: ${events[index].contact}', textAlign: TextAlign.center, style: eventDetailsStyle,),
                                          Text(tagsToString(events[index]), textAlign: TextAlign.center, style: eventDetailsStyle,),
                                                
                                          Divider(color: Colors.transparent),
                                          Divider(color: Colors.transparent),
                                          Divider(color: Colors.transparent),
                                          Divider(color: Colors.transparent),
                                        ],
                                      )
                                    );
                                  }
                                  }, 
                              ),
                            )
                          )                           
                        ],
                      )
                    )
                  ],
                ),        
              ],
            )
          );
  }
}