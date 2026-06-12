import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Casa y Jardín',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat', 
      ),
      home: HomePage(), 
    );
  }
}
