import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/auth_state.dart';
import 'state/player_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const MusicMvpApp());
}

class MusicMvpApp extends StatelessWidget {
  const MusicMvpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()..init()),
        ChangeNotifierProvider(create: (_) => PlayerState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music MVP',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1DB954),
            surface: Color(0xFF282828),
            onPrimary: Colors.black,
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF181818),
            selectedItemColor: Color(0xFF1DB954),
            unselectedItemColor: Color(0xFFB3B3B3),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF181818),
            indicatorColor: const Color(0xFF1DB954).withOpacity(0.2),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF1DB954));
              }
              return const IconThemeData(color: Color(0xFFB3B3B3));
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Color(0xFF1DB954), fontSize: 12, fontWeight: FontWeight.w600);
              }
              return const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12);
            }),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF282828),
            hintStyle: const TextStyle(color: Color(0xFFB3B3B3)),
            labelStyle: const TextStyle(color: Color(0xFFB3B3B3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1DB954), width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
            ),
          ),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFF1DB954),
            thumbColor: Colors.white,
            inactiveTrackColor: Color(0xFF535353),
            overlayColor: Color(0x201DB954),
          ),
          dividerColor: const Color(0xFF282828),
          useMaterial3: true,
        ),
        home: const RootGate(),
      ),
    );
  }
}

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))),
      );
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    return const MainShell();
  }
}
