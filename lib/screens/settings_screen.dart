import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notes_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';
import '../widgets/cork_background.dart';

/// شاشة الإعدادات
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CorkBackground(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildStatsCard(),
              const SizedBox(height: 12),
              _buildAppearanceCard(),
              const SizedBox(height: 12),
              _buildBehaviorCard(),
              const SizedBox(height: 12),
              _buildBackupCard(context),
              const SizedBox(height: 12),
              _buildAboutCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return _buildCard(
      title: 'إحصائيات',
      icon: Icons.insights,
      child: Consumer<NotesService>(
        builder: (_, service, __) {
          final total = service.notes.length;
          final home = service.notesByCategory(0).length;
          final work = service.notesByCategory(1).length;
          final family = service.notesByCategory(2).length;
          final pinned = service.pinnedNotes.length;
          final reminders =
              service.notes.where((n) => n.reminderDate != null).length;
          return Column(
            children: [
              _statRow('إجمالي الملاحظات', '$total'),
              _statRow('الرئيسية', '$home'),
              _statRow('العمل', '$work'),
              _statRow('العائلة', '$family'),
              _statRow('المثبتة', '$pinned'),
              _statRow('التذكيرات', '$reminders'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Consumer<SettingsService>(
      builder: (_, settings, __) {
        return _buildCard(
          title: 'المظهر',
          icon: Icons.palette,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('الوضع الداكن'),
                subtitle: Text(
                  settings.isDarkMode ? 'مُفعّل' : 'مُعطّل',
                  style: const TextStyle(fontSize: 12),
                ),
                value: settings.isDarkMode,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_brightness),
                title: const Text('وضع الثيم'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('فاتح'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('داكن'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('تلقائي'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) settings.setThemeMode(v);
                  },
                ),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text('اللغة'),
                trailing: Text('العربية'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBehaviorCard() {
    return Consumer<SettingsService>(
      builder: (_, settings, __) {
        return _buildCard(
          title: 'السلوك',
          icon: Icons.tune,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('ترتيب الملاحظات'),
                trailing: DropdownButton<NoteSortOrder>(
                  value: settings.sortOrder,
                  underline: const SizedBox(),
                  items: NoteSortOrder.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) settings.setSortOrder(v);
                  },
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: const Text('الاهتزاز عند الحفظ/الحذف'),
                subtitle: const Text(
                  'تشغيل تأثير اهتزاز خفيف عند العمليات المهمة',
                  style: TextStyle(fontSize: 12),
                ),
                value: settings.hapticEnabled,
                onChanged: settings.setHapticEnabled,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackupCard(BuildContext context) {
    return _buildCard(
      title: 'النسخ الاحتياطي',
      icon: Icons.backup,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.ios_share, color: Colors.blue),
            title: const Text('تصدير الملاحظات'),
            subtitle: const Text(
              'حفظ نسخة من جميع ملاحظاتك بصيغة JSON',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () => _exportNotes(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.green),
            title: const Text('استيراد الملاحظات'),
            subtitle: const Text(
              'ألصق نص JSON لإضافة الملاحظات إلى التطبيق',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () => _importNotes(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportNotes(BuildContext context) async {
    final service = context.read<NotesService>();
    if (service.notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد ملاحظات للتصدير')),
      );
      return;
    }
    final jsonStr = service.exportToJson();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              const Icon(Icons.ios_share, color: Colors.blue),
              const SizedBox(width: 8),
              Text('تصدير (${service.notes.length} ملاحظة)'),
            ],
          ),
        ),
        content: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'يمكنك نسخ النص ومشاركته أو حفظه لاحقًا:',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('نسخ'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonStr));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ البيانات إلى الحافظة'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('مشاركة'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await Share.share(
                  jsonStr,
                  subject: 'نسخة احتياطية - ملاحظاتي',
                );
              } catch (_) {
                // تجاهل أخطاء المشاركة على الويب
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _importNotes(BuildContext context) async {
    final textController = TextEditingController();
    bool replace = false;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          backgroundColor: AppColors.dialogBackground,
          title: const Directionality(
            textDirection: TextDirection.rtl,
            child: Text('استيراد ملاحظات'),
          ),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ألصق نص JSON الذي تم تصديره سابقًا:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: TextField(
                      controller: textController,
                      textDirection: TextDirection.ltr,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: '{"notes": [...]}',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'استبدال الملاحظات الحالية',
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: const Text(
                      'تحذير: سيتم حذف جميع الملاحظات الموجودة أولًا',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                    value: replace,
                    onChanged: (v) => setDialogState(() => replace = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('استيراد',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || !context.mounted) return;
    final text = textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('النص فارغ')),
      );
      return;
    }
    try {
      final service = context.read<NotesService>();
      final count = await service.importFromJson(text, replace: replace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استيراد $count ملاحظة بنجاح'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاستيراد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAboutCard(BuildContext context) {
    return _buildCard(
      title: 'حول التطبيق',
      icon: Icons.info,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.sticky_note_2),
            title: Text('اسم التطبيق'),
            trailing: Text('ملاحظاتي'),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.tag),
            title: Text('الإصدار'),
            trailing: Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('كيف أستخدم التطبيق؟'),
            onTap: () => _showHelp(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'حذف جميع الملاحظات',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmClearAll(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.noteYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.black87),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black38),
          Theme(
            data: ThemeData(
              dividerColor: Colors.black26,
              listTileTheme: const ListTileThemeData(
                iconColor: Colors.black87,
                textColor: Colors.black87,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('تأكيد', textDirection: TextDirection.rtl),
        content: const Text(
          'سيتم حذف جميع الملاحظات ولا يمكن التراجع. هل أنت متأكد؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      final service = context.read<NotesService>();
      await service.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع الملاحظات')),
        );
      }
    }
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('كيف أستخدم التطبيق؟', textDirection: TextDirection.rtl),
        content: const Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Text(
              'تطبيق ملاحظات لاصقة بتصميم لوحة الفلين.\n\n'
              '• اضغط على كومة الملاحظات في أسفل اليسار لإنشاء ملاحظة جديدة.\n'
              '• اضغط على ملاحظة لتعديلها.\n'
              '• اضغط طويلًا على ملاحظة لحذفها.\n'
              '• استخدم التبويبات العلوية للتنقل بين الفئات.\n'
              '• اضغط على الدبوس فوق الملاحظة لتغيير لونه.\n'
              '• زر البحث (أيقونة العدسة) للبحث في محتوى الملاحظات.\n'
              '• زر التقويم لعرض التذكيرات القادمة.\n'
              '• في شاشة التحرير: استخدم شريط التنسيق لتغيير الخط والألوان.',
              style: TextStyle(height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
