import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/image_upload/image_bloc.dart';
import 'package:intern01/bloc/navigation/navigation_bloc.dart';
import 'package:intern01/bloc/task/task_bloc.dart';
import 'package:intern01/bloc/theme/theme_bloc.dart';
import 'package:intern01/screens/splash_screen.dart';
import 'bloc/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<TaskBloc>(create: (context) => TaskBloc()),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
          lazy: false,
        ),
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(), lazy: false),
        BlocProvider<ImageBloc>(create: (context) => ImageBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
