import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern01/bloc/theme/theme_bloc.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80),
          SizedBox(height: 20),
          Text('Settings Page', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('App settings and preferences will appear here'),
          SizedBox(height: 30),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return FloatingActionButton(
                onPressed: () {
                  if (themeState is DarkTheme) {
                    context.read<ThemeBloc>().add(ToggleLight());
                  } else {
                    context.read<ThemeBloc>().add(ToggleDark());
                  }
                },
                child: Icon(
                  themeState is DarkTheme ? Icons.light_mode : Icons.dark_mode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
