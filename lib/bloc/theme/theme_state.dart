part of 'theme_bloc.dart';

@immutable
sealed class ThemeState {
  final ThemeData themeData;
  const ThemeState(this.themeData);
}

final class ThemeInitial extends ThemeState {
  ThemeInitial() : super(ThemeData.light());
}

final class LightTheme extends ThemeState {
  LightTheme()
    : super(
        ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
      );
}

class DarkTheme extends ThemeState {
  DarkTheme()
    : super(
        ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            brightness: Brightness.dark,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.black,
          textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      );
}
