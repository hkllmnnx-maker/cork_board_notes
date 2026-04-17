import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/notes_service.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notesService = NotesService();
  await notesService.init();
  final settingsService = SettingsService();
  await settingsService.init();

  // مزامنة أوّلية لترتيب الفرز من الإعدادات
  notesService.setSortOrder(settingsService.sortOrder);
  // تحديث الفرز عند تغيره من الإعدادات
  settingsService.addListener(() {
    notesService.setSortOrder(settingsService.sortOrder);
  });

  runApp(CorkBoardApp(
    notesService: notesService,
    settingsService: settingsService,
  ));
}

class CorkBoardApp extends StatelessWidget {
  final NotesService notesService;
  final SettingsService settingsService;
  const CorkBoardApp({
    super.key,
    required this.notesService,
    required this.settingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesService>.value(value: notesService),
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
      ],
      child: Consumer<SettingsService>(
        builder: (_, settings, __) {
          return MaterialApp(
            title: 'ملاحظاتي',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: settings.themeMode,
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
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.noteYellow,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'sans-serif',
      scaffoldBackgroundColor: AppColors.corkBoard,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.noteYellow,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'sans-serif',
      scaffoldBackgroundColor: AppColors.corkBoardDark,
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF3A2F25),
      ),
    );
  }
}
