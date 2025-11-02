import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/user.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(MathApp(appState: appState));
}

class MathApp extends StatelessWidget {
  const MathApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quant+',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CFF),
            secondary: const Color(0xFF6BF0A8),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F6FD),
          textTheme: GoogleFonts.nunitoTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1F1C3D),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          primaryTextTheme: GoogleFonts.nunitoTextTheme(),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(textStyle: GoogleFonts.nunito()),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
          ),
          chipTheme: ChipThemeData(
            selectedColor: const Color(0xFF8B5CFF).withOpacity(0.18),
            labelStyle: const TextStyle(color: Color(0xFF1F1C3D)),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.currentUser;
        if (user == null) {
          return const LoginPage();
        }

        if (user.role == UserRole.admin) {
          return const AdminDashboardPage();
        }

        return const HomePage();
      },
    );
  }
}
