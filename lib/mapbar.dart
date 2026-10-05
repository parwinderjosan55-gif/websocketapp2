import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class mapscreen extends StatefulWidget {
  const mapscreen ({super.key});
  @override
  State<mapscreen> createState()=> _mapscreen();
}
class _mapscreen extends State<mapscreen>{
  @override
  Widget build (BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("mapbar"),),
      body: Center(
        child: Column(
          children: [

          ],
        ),
      )
    );
  }
}
