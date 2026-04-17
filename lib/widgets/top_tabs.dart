import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// شريط التبويبات العلوي بتصميم الألسنة (tabs) كما في الصورة
class TopTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const TopTabs({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    // الترتيب في الواجهة (من اليمين لليسار):
    // الرئيسية - العمل - العائلة - الإعدادات
    final tabs = [
      _TabData('الرئيسية', AppColors.tabHome, Icons.push_pin),
      _TabData('العمل', AppColors.tabWork, Icons.work),
      _TabData('العائلة', AppColors.tabFamily, Icons.family_restroom),
      _TabData('الإعدادات', AppColors.tabSettings, Icons.settings),
    ];

    return SizedBox(
      height: 54,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabItem(
                data: tabs[i],
                isActive: currentIndex == i,
                onTap: () => onTabChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabData {
  final String label;
  final Color color;
  final IconData icon;
  _TabData(this.label, this.color, this.icon);
}

class _TabItem extends StatelessWidget {
  final _TabData data;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isActive
                  ? Color.lerp(data.color, Colors.white, 0.25)!
                  : data.color.withValues(alpha: 0.55),
              isActive ? data.color : data.color.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 16,
              color: Colors.black.withValues(alpha: isActive ? 0.85 : 0.6),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                data.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withValues(alpha: isActive ? 0.9 : 0.65),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
