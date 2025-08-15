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
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: const Color(0xFF22223B),
            onPrimary: Colors.white,
            secondary: const Color(0xFF4A4E69),
            onSecondary: Colors.white,
            error: Colors.redAccent,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF22223B),
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          textTheme: ThemeData.light().textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF22223B),
            foregroundColor: Colors.white,
          ),
        ),
      );
}

class DarkTheme extends ThemeState {
  DarkTheme()
    : super(
        ThemeData.dark().copyWith(
          colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.white,
            onSecondary: Colors.black,
            error: Colors.redAccent,
            onError: Colors.black,
            surface: const Color(0xFF23262F),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF181A20),
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          scaffoldBackgroundColor: Color(0xFF181A20),
          cardColor: Color(0xFF23262F),
          textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
      );
}
