import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:regina_app/core/router/app_router.dart';
import 'package:regina_app/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // necesario para async en main
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ReginaApp()),);
}

class ReginaApp extends StatelessWidget {
  const ReginaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme(selectedColor: 1, isDarkMode: false).getThemeData(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
