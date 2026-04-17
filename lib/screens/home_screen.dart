import 'package:flutter/material.dart';
import '../widgets/top_tabs.dart';
import 'board_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية التي تحوي التبويبات الأربعة
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopTabs(
              currentIndex: _currentIndex,
              onTabChanged: (i) => setState(() => _currentIndex = i),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  BoardScreen(categoryIndex: 0), // الرئيسية
                  BoardScreen(categoryIndex: 1), // العمل
                  BoardScreen(categoryIndex: 2), // العائلة
                  SettingsScreen(),              // الإعدادات
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
