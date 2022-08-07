import 'package:flutter/material.dart';


class AboutAppPage extends StatefulWidget {
  @override
  _AboutAppPageState createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size;


    return Stack(
      children: <Widget>[
        Container(
          height: size.height,
          width: size.width,
        ),
        Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
            backgroundColor: Colors.white70,
            elevation: 0.0,
            centerTitle: true,
            title: Column(
                children: <Widget>[
                  Text('About App',style: TextStyle(color: Colors.black54)),
                ],
              ) 
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text("Lagos events provides a free event hub; users can discovery and upload events using our simple but robust facility. Users can also set reminder, Who wants to discover an events only to forget about it on the D-day. ")
              ),

              Divider(color: Colors.grey,),
            ],
          ),
        ),
      ],
    );
  }
}