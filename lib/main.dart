import 'package:delidash/page/choseregister.dart';
import 'package:delidash/page/loginpage.dart';
import 'package:delidash/page/registeruser.dart';
import 'package:flutter/material.dart';
import 'package:delidash/page/Fritspage.dart';

void main() {
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
      home: const Registeruser(),
    );
  }
}
