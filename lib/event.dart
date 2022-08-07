import 'package:flutter/material.dart';

class Event{
  int id; 
  String title;
  String venue;
  DateTime date;
  List<int> fees;
  List<String> tags;
  String imageUrl;
  int ranking;  //negative-- uncleared, positive below 100 is regular, above 100 is featured
  String contact;

  Event({
    @required this.title, 
    this.id,
    this.venue, 
    this.date, 
    this.fees,
    this.imageUrl,
    this.tags,
    this.ranking,
    this.contact
  });

}

