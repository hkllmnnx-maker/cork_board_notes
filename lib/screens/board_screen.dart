import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/cork_background.dart';
import '../widgets/sticky_note_card.dart';
import 'note_edit_screen.dart';

/// شاشة اللوحة الرئيسية للفئة المحددة
class BoardScreen extends StatelessWidget {
  final int categoryIndex;
  const BoardScreen({super.key, required this.categoryIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesService>(
      builder: (context, service, _) {
        final notes = service.notesByCategory(categoryIndex);
        return CorkBackground(
          child: Stack(
            children: [
              // شبكة الملاحظات
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 80),
                child: notes.isEmpty
                    ? _buildEmptyState(context)
                    : GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (_, i) {
                          final n = notes[i];
                          return StickyNoteCard(
                            note: n,
                            onTap: () => _openNote(context, n),
                            onLongPress: () => _confirmDelete(context, n),
                          );
                        },
                      ),
              ),
              // زر إضافة ملاحظة (FAB) - أسفل اليسار (كومة الملاحظات)
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildStackFab(context),
              ),
              // أزرار أسفل اليمين
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    _circleButton(
                      icon: Icons.menu,
                      onTap: () => _showQuickMenu(context),
                    ),
                    const SizedBox(width: 8),
                    _circleButton(
                      icon: Icons.calendar_month,
                      onTap: () => _showCalendarList(context, notes),
                    ),
                  ],
                ),
              ),
              // زر المساعدة
              Positioned(
                bottom: 16,
                right: MediaQuery.of(context).size.width / 2 - 24,
                child: _circleButton(
                  icon: Icons.help_outline,
                  onTap: () => _showHelp(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.noteYellow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 48, color: Colors.brown),
            SizedBox(height: 10),
            Text(
              'لا توجد ملاحظات بعد\nاضغط على الكومة لإضافة ملاحظة',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(side: BorderSide(color: Colors.black38)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildStackFab(BuildContext context) {
    return GestureDetector(
      onTap: () => _openNote(context, null),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الطبقات المتعددة (كومة ملاحظات بألوان مختلفة)
            Positioned(
              left: 4,
              top: 18,
              child: _layer(Colors.pink.shade200, 54),
            ),
            Positioned(
              left: 10,
              top: 12,
              child: _layer(Colors.lightBlue.shade200, 54),
            ),
            Positioned(
              left: 16,
              top: 6,
              child: _layer(Colors.green.shade200, 54),
            ),
            Positioned(
              left: 22,
              top: 0,
              child: _layer(AppColors.noteYellow, 54),
            ),
            const Positioned(
              bottom: 6,
              child: Icon(Icons.add, size: 20, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _layer(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Future<void> _openNote(BuildContext context, Note? existing) async {
    final service = context.read<NotesService>();
    Note note;
    bool isNew = false;
    if (existing == null) {
      note = await service.createNewNote(categoryIndex: categoryIndex);
      isNew = true;
    } else {
      note = existing;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditScreen(note: note, isNew: isNew),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('حذف الملاحظة', textDirection: TextDirection.rtl),
        content: const Text(
          'هل تريد حذف هذه الملاحظة نهائيًا؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await context.read<NotesService>().deleteNote(note.id);
    }
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.noteYellow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('ملاحظة جديدة'),
                onTap: () {
                  Navigator.pop(context);
                  _openNote(context, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('حول التطبيق'),
                onTap: () {
                  Navigator.pop(context);
                  _showHelp(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarList(BuildContext context, List<Note> notes) {
    final reminders = notes.where((n) => n.reminderDate != null).toList()
      ..sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.dialogBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التذكيرات القادمة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (reminders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('لا توجد تذكيرات'),
                  )
                else
                  ...reminders.map((n) {
                    final firstLine = n.content.split('\n').first.trim();
                    final title = firstLine.isEmpty ? 'ملاحظة بدون عنوان' : firstLine;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Colors.orange),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${DateFormatter.arabicDate(n.reminderDate!)} • ${DateFormatter.reminderLabel(n.reminderDate!)}',
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('حول التطبيق', textDirection: TextDirection.rtl),
        content: const Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'تطبيق ملاحظات لاصقة بتصميم لوحة الفلين.\n\n'
            '• اضغط على كومة الملاحظات لإنشاء ملاحظة جديدة.\n'
            '• اضغط على ملاحظة لتعديلها.\n'
            '• اضغط طويلًا على ملاحظة لحذفها.\n'
            '• استخدم التبويبات العلوية للتنقل بين الفئات.',
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
