import 'package:final_note_app/firebase_options.dart';
import 'package:final_note_app/screens/home_screen.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
    runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Final Note App',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
    );
  }
}