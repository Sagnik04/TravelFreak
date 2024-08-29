import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
create(var name,place,description,email,uid,docid)async{
  await FirebaseFirestore.instance.collection('users').doc(docid).set({
    'Name' : name,
    'Place' : place,
    'Description' : description,
    'Email' : email,
    'uid' : uid,
    'Date' : DateFormat('yMMMMd').format(DateTime.now()).toString(),
    'Doc Id' : docid,

  });
}
update(var docid,field)async{
  await FirebaseFirestore.instance.collection('users').doc(docid).update(field);
}
delete()async{
  await FirebaseFirestore.instance.collection('users').doc().delete();
}