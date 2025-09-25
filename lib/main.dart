import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delidash/firebase_options.dart';
import 'package:delidash/page/AddAddessPage.dart';
import 'package:delidash/page/choseregister.dart';
import 'package:delidash/page/loginpage.dart';
import 'package:delidash/page/registeruser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:delidash/page/Fritspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Connnect to FireStore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AddAddressPage(),
    );
  }
}
