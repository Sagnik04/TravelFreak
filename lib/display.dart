import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelfreak_playstore/editup1.dart';
import 'package:travelfreak_playstore/func.dart';
import 'package:travelfreak_playstore/login.dart';
import 'package:travelfreak_playstore/main.dart';
import 'package:travelfreak_playstore/profile.dart';
import 'package:travelfreak_playstore/main.dart';

import 'admanager.dart';

class Display extends StatefulWidget {  @override
State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  var search = "";
  var value;
  String email = "";
  var Uid = "";
  late InterstitialAd _interstitialAd;
  bool _isADLoaded = false;
  bool isConnected = false;
  StreamSubscription? _internetSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    enter();
    _internetSubscription = InternetConnection().onStatusChange.listen((event) {
      print(event);
      switch(event){
        case InternetStatus.connected:
          setState(() {
            isConnected = true;
          });

          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnected = false;
          });

          break;
        default:
          setState(() {
            isConnected = false;
          });
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      await AdsManager.loadUnityAD();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _internetSubscription?.cancel();
  }
  void enter ()async{
    SharedPreferences spb = await SharedPreferences.getInstance();
    email = spb.getString('EI').toString();
    Uid = spb.getString('UID').toString();
    setState(() {

    });
  }
  void _initAD(){
    InterstitialAd.load(
      adUnitId: '',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (error){},
      ),
    );
  }
  void onAdLoaded(InterstitialAd ad){
    _interstitialAd = ad;
    _isADLoaded = true;
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad){
          _interstitialAd.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad,error){
          _interstitialAd.dispose();
        }
    );
  }



  Future<void> _refresh() async{
    setState(() {

    });
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){

                Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile()));

              }, icon: Icon(Icons.account_circle_outlined),color: Colors.black87,),

              IconButton(onPressed: (){

                _auth.signOut().then((value) {

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));

                }).onError((error, stackTrace) {
                  print("Logut ${error.toString()}");


                });

              }, icon: Icon(Icons.logout),color: Colors.black87,),
            ],
          )

        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value){
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                  filled: true,
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  )
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: StreamBuilder(stream: FirebaseFirestore.instance.collection('users').orderBy('Place').startAt([search]).endAt([search + "\uf8ff"]).snapshots(),
            builder: (context,travSnapshot){
              if(travSnapshot.connectionState == ConnectionState.waiting || !isConnected){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              else{
                final travdocs = travSnapshot.data!.docs;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                      itemCount: travdocs.length,
                      itemBuilder: (context,index){
                        return Dismissible(
                          key: Key(travdocs[index]['Name']),
                          background: Container(
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction){
                            if(_auth.currentUser!.email == travdocs[index]['Email']){
                              FirebaseFirestore.instance.collection('users').doc(travdocs[index]['Doc Id']).delete();
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("You cannot delete other's post"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }

                          },
                          direction: DismissDirection.endToStart,

                          child: Card(
                            child: ListTile(
                              title: Text(travdocs[index]['Place'],style: TextStyle(fontSize: 40),),
                              subtitle: Text(travdocs[index]['Name'],style: TextStyle(fontSize: 24),),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(travdocs[index]['Date'],style: TextStyle(fontSize: 16),),
                                ],
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Edit(place: travdocs[index]['Place'], name: travdocs[index]['Name'], description: travdocs[index]['Description'])));
                              },
                            ),
                          ),
                        );
                      }
                  ),
                );
              }
            }
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        if(isConnected){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
          await AdsManager.showIntAd();
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:Text("Something went wrong.Try again"),
                behavior: SnackBarBehavior.floating,
              )
          );
        };

      },child: Icon(Icons.add,color: Colors.brown,),
        backgroundColor: Colors.amber,
        shape: CircleBorder(),),
    );
  }}
