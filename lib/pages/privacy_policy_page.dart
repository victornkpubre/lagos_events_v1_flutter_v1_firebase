import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

String intro = "It is important that you understand what information Lagos Events collects and uses.No information is collected covertly and all personal information is stored on the user\'s phone";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    TextStyle style = TextStyle(color: Colors.grey);


    return Stack(
      children: <Widget>[
        Container(
          height: size.height,
          width: size.width,
  //        decoration: const BoxDecoration(
  //            image:  DecorationImage(
  //              image: AssetImage('assets/images/Moonlit_Asteroid.jpg'),
  //              fit: BoxFit.cover
  //            )
  //        ),
        ),
        Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
            backgroundColor: Colors.white70,
            elevation: 0.0,
            centerTitle: true,
            title: Column(
                children: <Widget>[
                  Text('Privacy Policy',style: TextStyle(color: Colors.black54)),
                ],
              ) 
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text(intro)
              ),

              Divider(color: Colors.grey,),

              Container(
                width: size.width,
                padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                child: Text("Information Collection", textAlign: TextAlign.left,)
              ),
              
              Container(
                width: size.width*0.9,
                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                child: Text("Lagos Events does not save or collect any login information; information related to saved and uploaded events are stored on the users phone; Alll information related to events are stored on a remote database",
                  textAlign: TextAlign.left,
                )
              ),

              Divider(color: Colors.grey,)

            ],
          ),
        ),
      ],
    );
  }
}