import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/flash_screen.dart';
import 'package:netflix_clone/utils/colors.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Netflix Clone',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryWhite,
            primary: primaryWhite,
            secondary: secondaryWhite,
            tertiary: Colors.white,
            inversePrimary: Colors.black
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlack,
            primary: primaryBlack,
            secondary: secondaryBlack,
            tertiary: Colors.black,
            inversePrimary: Colors.white
          ),
          useMaterial3: true,
        ),
        themeMode: themeProvider.themeMode,
        home: const FlashScreen(),
      ),
    );
  }
}
