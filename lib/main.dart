import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/notes_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notesService = NotesService();
  await notesService.init();
  runApp(CorkBoardApp(notesService: notesService));
}

class CorkBoardApp extends StatelessWidget {
  final NotesService notesService;
  const CorkBoardApp({super.key, required this.notesService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotesService>.value(
      value: notesService,
      child: MaterialApp(
        title: 'ملاحظاتي',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF9EE8C),
          ),
          useMaterial3: true,
          fontFamily: 'sans-serif',
        ),
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
