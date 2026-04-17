import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notes_service.dart';
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
              _buildCard(
                title: 'إحصائيات',
                child: Consumer<NotesService>(
                  builder: (_, service, __) {
                    final total = service.notes.length;
                    final home =
                        service.notesByCategory(0).length;
                    final work =
                        service.notesByCategory(1).length;
                    final family =
                        service.notesByCategory(2).length;
                    return Column(
                      children: [
                        _statRow('إجمالي الملاحظات', '$total'),
                        _statRow('الرئيسية', '$home'),
                        _statRow('العمل', '$work'),
                        _statRow('العائلة', '$family'),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: 'الإعدادات العامة',
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.language),
                      title: Text('اللغة'),
                      trailing: Text('العربية'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.palette),
                      title: Text('الثيم'),
                      trailing: Text('لوحة الفلين'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: 'حول التطبيق',
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('اسم التطبيق'),
                      trailing: Text('Cork Board Notes'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.tag),
                      title: Text('الإصدار'),
                      trailing: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever,
                          color: Colors.red),
                      title: const Text(
                        'حذف جميع الملاحظات',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _confirmClearAll(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black38),
          child,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
      final ids = service.notes.map((e) => e.id).toList();
      for (final id in ids) {
        await service.deleteNote(id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع الملاحظات')),
        );
      }
    }
  }
}
