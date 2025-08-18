import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ToDoList/bloc/image_upload/image_bloc.dart';
import 'package:ToDoList/bloc/navigation/cubit/navigation_cubit.dart';
import 'package:ToDoList/bloc/task/task_bloc.dart';
import 'package:ToDoList/bloc/theme/theme_bloc.dart';
import 'package:ToDoList/screens/splash_screen.dart';
import 'package:ToDoList/screens/task_page.dart';
import 'bloc/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<TaskBloc>(create: (context) => TaskBloc()),

        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(), lazy: false),
        BlocProvider<ImageBloc>(create: (context) => ImageBloc()),
        BlocProvider(create: (_) => NavigationCubit(), child: TaskPage()),
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
