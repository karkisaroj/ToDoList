import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intern01/myapp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
