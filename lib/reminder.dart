import 'package:flutter/material.dart';

class Reminder{
  String name;
  int alertTimeYear;
  int alertTimeMonth;
  int alertTimeDay;
  int alertTimeHour;
  int   alertId;
  int eventId;

  Reminder({
    @required this.name, 
    @required this.alertTimeYear, 
    @required this.alertTimeMonth, 
    @required this.alertTimeDay, 
    @required this.alertTimeHour, 
    @required this.alertId,
    @required this.eventId, 
  });

  Map<String, dynamic> toJson(){
    final map = {
        'name' : name,
        'alertTimeYear' : alertTimeYear,
        'alertTimeMonth' : alertTimeMonth,
        'alertTimeDay' : alertTimeDay,
        'alertTimeHour' : alertTimeHour,
        'alertId' : alertId,
        'eventId' : eventId,
      };
        return map;
  }

  Reminder.fromJson(Map<String, dynamic> json)
    : name = json['name'],
    alertTimeYear = json['alertTimrYear'],
    alertTimeMonth = json['alertTimrMonth'],
    alertTimeDay = json['alertTimrDay'],
    alertTimeHour = json['alertTimrHour'],
    alertId = json['alertId'],
    eventId = json['eventId'];
}