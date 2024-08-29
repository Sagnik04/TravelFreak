import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Edit extends StatelessWidget {
  var place,name,description;
  Edit({required this.place,required this.name,required this.description});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Travel",style: TextStyle(fontFamily: 'TitleFont',fontWeight: FontWeight.bold,color: Colors.brown),),
            Text("Freak",style: TextStyle(fontFamily: 'TitleFont',fontWeight: FontWeight.bold,color: Colors.amber),),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(place,style: TextStyle(fontSize: 80,fontWeight: FontWeight.bold),maxLines: 1,),
              AutoSizeText(name,style: TextStyle(fontSize: 60),maxLines: 1,),
              Card(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(description,style: TextStyle(fontSize: 24),),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
