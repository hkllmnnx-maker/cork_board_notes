import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../utils/haptics.dart';
import '../widgets/cork_background.dart';
import '../widgets/pushpin.dart';
import '../widgets/sticky_note_card.dart';
import 'note_edit_screen.dart';
import 'search_screen.dart';

/// شاشة اللوحة الرئيسية للفئة المحددة
class BoardScreen extends StatefulWidget {
  final int categoryIndex;
  const BoardScreen({super.key, required this.categoryIndex});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  /// لون الدبوس المفعل للتصفية (null = الكل)
  int? _filterPin;

  int get categoryIndex => widget.categoryIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesService>(
      builder: (context, service, _) {
        var notes = service.notesByCategory(categoryIndex);
        if (_filterPin != null) {
          notes = notes.where((n) => n.pinColor == _filterPin).toList();
        }
        // الملاحظات المثبتة (من أي فئة) تظهر فقط في التبويب الرئيسي
        final pinnedNotes = categoryIndex == 0 ? service.pinnedNotes : <Note>[];
        return CorkBackground(
          child: Stack(
            children: [
              // شبكة الملاحظات + شريط المثبتة (إن وُجدت)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 80),
                child: notes.isEmpty && pinnedNotes.isEmpty
                    ? _buildEmptyState(context)
                    : Column(
                        children: [
                          if (_filterPin != null) ...[
                            _buildFilterChip(),
                            const SizedBox(height: 8),
                          ],
                          if (pinnedNotes.isNotEmpty) ...[
                            _buildPinnedBar(context, pinnedNotes),
                            const SizedBox(height: 8),
                          ],
                          Expanded(
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
                                        onLongPress: () =>
                                            _confirmDelete(context, n),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
              // زر إضافة ملاحظة (FAB) - أسفل اليسار (كومة الملاحظات)
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildStackFab(context),
              ),
              // شريط أزرار أسفل اليمين
              Positioned(
                bottom: 16,
                right: 16,
                child: Row(
                  children: [
                    _circleButton(
                      icon: Icons.search,
                      onTap: () => _openSearch(context),
                    ),
                    const SizedBox(width: 6),
                    _circleButtonWithBadge(
                      icon: Icons.filter_list,
                      hasBadge: _filterPin != null,
                      onTap: () => _showFilterDialog(context),
                    ),
                    const SizedBox(width: 6),
                    _circleButton(
                      icon: Icons.calendar_month,
                      onTap: () => _showCalendarList(context, notes),
                    ),
                    const SizedBox(width: 6),
                    _circleButton(
                      icon: Icons.menu,
                      onTap: () => _showQuickMenu(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedBar(BuildContext context, List<Note> pinnedNotes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.push_pin, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'المثبتة (${pinnedNotes.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pinnedNotes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final n = pinnedNotes[i];
                  return SizedBox(
                    width: 95,
                    child: StickyNoteCard(
                      note: n,
                      onTap: () => _openNote(context, n),
                      onLongPress: () => _confirmDelete(context, n),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

  Widget _circleButtonWithBadge({
    required IconData icon,
    required bool hasBadge,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _circleButton(icon: icon, onTap: onTap),
        if (hasBadge)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip() {
    final pinIndex = _filterPin!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black38),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Pushpin(colorIndex: pinIndex, size: 16),
            const SizedBox(width: 6),
            Text(
              'يظهر فقط: ${AppColors.pinName(pinIndex)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => setState(() => _filterPin = null),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('تصفية حسب الأولوية',
            textDirection: TextDirection.rtl),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('عرض الكل'),
                trailing: _filterPin == null
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() => _filterPin = null);
                  Navigator.of(dialogContext).pop();
                },
              ),
              const Divider(height: 1),
              for (int i = 0; i < AppColors.pinNames.length; i++)
                ListTile(
                  leading: Pushpin(colorIndex: i, size: 22),
                  title: Text(AppColors.pinName(i)),
                  trailing: _filterPin == i
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => _filterPin = i);
                    Navigator.of(dialogContext).pop();
                  },
                ),
            ],
          ),
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

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(categoryIndex: categoryIndex),
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
      final settings = context.read<SettingsService>();
      await context.read<NotesService>().deleteNote(note.id);
      if (context.mounted) {
        Haptics.medium(settings);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الملاحظة'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.noteYellow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('ملاحظة جديدة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openNote(context, null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('بحث في الملاحظات'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openSearch(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text('تصفية حسب الأولوية'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showFilterDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('كيف أستخدم التطبيق؟'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showHelp(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('حول التطبيق'),
                onTap: () {
                  Navigator.pop(sheetContext);
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
                          '${DateFormatter.arabicDate(n.reminderDate!)} • ${DateFormatter.time12(n.reminderDate!)}\n${DateFormatter.reminderLabel(n.reminderDate!)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
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
