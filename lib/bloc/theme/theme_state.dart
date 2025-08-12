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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
      );
}

class DarkTheme extends ThemeState {
  DarkTheme()
    : super(
        ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
      );
}
