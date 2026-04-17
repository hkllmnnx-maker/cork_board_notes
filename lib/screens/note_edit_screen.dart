import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/cork_background.dart';
import 'calendar_picker_dialog.dart';

/// شاشة إنشاء/تعديل ملاحظة
class NoteEditScreen extends StatefulWidget {
  final Note note;
  final bool isNew;
  const NoteEditScreen({super.key, required this.note, this.isNew = false});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _controller;
  late Note _note;
  bool _showFormatBar = false;
  bool _showOptionsMenu = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _controller = TextEditingController(text: _note.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = context.read<NotesService>();
    final updated = _note.copyWith(content: _controller.text);
    if (widget.isNew) {
      await service.addNote(updated);
    } else {
      await service.updateNote(updated);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  Future<void> _pickReminderDate() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => ArabicCalendarDialog(initialDate: _note.reminderDate),
    );
    if (result != null) {
      setState(() {
        _note = _note.copyWith(reminderDate: result);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تعيين تذكير ليوم ${DateFormatter.arabicDate(result)} (${DateFormatter.reminderLabel(result)})',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الملاحظة فارغة')),
      );
      return;
    }
    try {
      await Share.share(text);
    } catch (_) {
      // تجاهل أخطاء المشاركة على الويب
    }
  }

  Future<void> _duplicateNote() async {
    final service = context.read<NotesService>();
    final updated = _note.copyWith(content: _controller.text);
    // احفظ الحالية أولًا إن كانت جديدة
    if (widget.isNew) {
      await service.addNote(updated);
    } else {
      await service.updateNote(updated);
    }
    await service.duplicateNote(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تكرار الملاحظة')),
    );
    Navigator.of(context).pop(true);
  }

  void _toggleReadOnly() {
    setState(() {
      _note = _note.copyWith(isReadOnly: !_note.isReadOnly);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_note.isReadOnly
            ? 'تم تفعيل وضع القراءة فقط'
            : 'تم إلغاء وضع القراءة فقط'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePinToHome() {
    setState(() {
      _note = _note.copyWith(isPinnedToHome: !_note.isPinnedToHome);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_note.isPinnedToHome
            ? 'تم التثبيت في الشاشة الرئيسية'
            : 'تم إلغاء التثبيت'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CorkBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildNoteArea(),
                    if (_showOptionsMenu) _buildOptionsMenu(),
                  ],
                ),
              ),
              if (_showFormatBar) _buildFormatBar(),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // زر الإطار العلوي يعرض الفئة الحالية مثل "العمل"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.tabWork, AppColors.noteYellowDark],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black54),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.work, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _categoryName(_note.categoryIndex),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // زر القائمة (menu)
            _smallRoundButton(
              icon: Icons.list,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 6),
            // زر الملاحظة (يشبه شكل الملاحظة الصفراء)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.noteYellow,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black54),
              ),
              child: const Icon(Icons.sticky_note_2, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallRoundButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.noteYellow,
      shape: const CircleBorder(side: BorderSide(color: Colors.black54)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }

  String _categoryName(int index) {
    switch (index) {
      case 1:
        return 'العمل';
      case 2:
        return 'العائلة';
      default:
        return 'الرئيسية';
    }
  }

  Widget _buildNoteArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.noteYellow, AppColors.noteYellowDark],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // شريط أدوات داخل الملاحظة
            Padding(
              padding: const EdgeInsets.all(8),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    _noteToolButton(Icons.menu, () {
                      setState(() {
                        _showOptionsMenu = !_showOptionsMenu;
                      });
                    }),
                    const SizedBox(width: 8),
                    _noteToolButton(Icons.access_time, _pickReminderDate),
                    const SizedBox(width: 8),
                    _noteToolButton(Icons.calendar_today, _pickReminderDate),
                    const Spacer(),
                    _noteToolButton(Icons.info_outline, _showInfo),
                  ],
                ),
              ),
            ),
            // محرر النص
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: TextField(
                  controller: _controller,
                  readOnly: _note.isReadOnly,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontSize: _note.fontSize,
                    color: Colors.black87,
                    height: 1.5,
                    fontWeight:
                        _note.isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle:
                        _note.isItalic ? FontStyle.italic : FontStyle.normal,
                    decoration: _buildTextDecoration(),
                    backgroundColor: _note.isHighlighted
                        ? Colors.yellow.shade600.withValues(alpha: 0.5)
                        : null,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'نص ملاحظتك',
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // شريط أدوات سفلي داخل الملاحظة
            Padding(
              padding: const EdgeInsets.all(8),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    _noteToolButton(Icons.text_fields, () {
                      setState(() {
                        _showFormatBar = !_showFormatBar;
                      });
                    }),
                    const Spacer(),
                    _noteToolButton(Icons.attach_file, _showAttachmentNotice),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextDecoration _buildTextDecoration() {
    final list = <TextDecoration>[];
    if (_note.isUnderline) list.add(TextDecoration.underline);
    if (_note.isStrikethrough) list.add(TextDecoration.lineThrough);
    if (list.isEmpty) return TextDecoration.none;
    if (list.length == 1) return list.first;
    return TextDecoration.combine(list);
  }

  Widget _noteToolButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black54),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('معلومات الملاحظة', textDirection: TextDirection.rtl),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تاريخ الإنشاء: ${_fmt(_note.createdAt)}'),
              const SizedBox(height: 6),
              Text('آخر تعديل: ${_fmt(_note.updatedAt)}'),
              const SizedBox(height: 6),
              Text('عدد الأحرف: ${_controller.text.length}'),
              if (_note.reminderDate != null) ...[
                const SizedBox(height: 6),
                Text('التذكير: ${_fmt(_note.reminderDate!)}'),
              ],
            ],
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

  String _fmt(DateTime d) => DateFormatter.dateTime(d);

  void _showAttachmentNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المرفقات قادمة قريبًا'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return Positioned(
      top: 60,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: AppColors.noteYellow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _menuItem(Icons.share, 'مشاركة ملاحظة...', () {
                setState(() => _showOptionsMenu = false);
                _shareNote();
              }),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.content_copy, 'تكرار ملاحظة', () {
                setState(() => _showOptionsMenu = false);
                _duplicateNote();
              }),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(
                _note.isReadOnly ? Icons.lock_open : Icons.visibility,
                'وضع القراءة فقط',
                () {
                  setState(() => _showOptionsMenu = false);
                  _toggleReadOnly();
                },
              ),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.event, 'أضف حدثًا إلى تقاويم الهاتف', () {
                setState(() => _showOptionsMenu = false);
                _pickReminderDate();
              }),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.widgets, 'التثبيت في الشاشة الرئيسية', () {
                setState(() => _showOptionsMenu = false);
                _togglePinToHome();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.noteYellow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _formatButton(
              label: 'Aa',
              active: false,
              onTap: () {},
            ),
            const SizedBox(width: 4),
            _fontSizeButton(),
            const SizedBox(width: 4),
            _formatButton(
              icon: Icons.brush,
              active: _note.isHighlighted,
              onTap: () => setState(() {
                _note = _note.copyWith(isHighlighted: !_note.isHighlighted);
              }),
            ),
            const SizedBox(width: 4),
            _formatButton(
              label: 'A',
              active: false,
              onTap: _pickPinColor,
            ),
            const SizedBox(width: 4),
            _formatButton(
              icon: Icons.strikethrough_s,
              active: _note.isStrikethrough,
              onTap: () => setState(() {
                _note = _note.copyWith(isStrikethrough: !_note.isStrikethrough);
              }),
            ),
            const SizedBox(width: 4),
            _formatButton(
              icon: Icons.format_underline,
              active: _note.isUnderline,
              onTap: () => setState(() {
                _note = _note.copyWith(isUnderline: !_note.isUnderline);
              }),
            ),
            const SizedBox(width: 4),
            _formatButton(
              icon: Icons.format_italic,
              active: _note.isItalic,
              onTap: () => setState(() {
                _note = _note.copyWith(isItalic: !_note.isItalic);
              }),
            ),
            const SizedBox(width: 4),
            _formatButton(
              icon: Icons.format_bold,
              active: _note.isBold,
              onTap: () => setState(() {
                _note = _note.copyWith(isBold: !_note.isBold);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fontSizeButton() {
    final percent = ((_note.fontSize / 14.0) * 100).toInt();
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black54),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('حجم الخط'),
              content: StatefulBuilder(
                builder: (_, setState2) => SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Slider(
                        value: _note.fontSize,
                        min: 10,
                        max: 32,
                        divisions: 22,
                        label: _note.fontSize.toInt().toString(),
                        onChanged: (v) {
                          setState2(() {});
                          setState(() {
                            _note = _note.copyWith(fontSize: v);
                          });
                        },
                      ),
                      Text('${_note.fontSize.toInt()}'),
                    ],
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
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _formatButton({
    IconData? icon,
    String? label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? Colors.orange.shade200 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: active ? Colors.deepOrange : Colors.black54),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 32,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 18, color: Colors.black87)
                : Text(
                    label ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPinColor() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('اختر لون الدبوس', textDirection: TextDirection.rtl),
        content: Wrap(
          spacing: 12,
          children: [
            for (int i = 0; i < 4; i++)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(i),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pinColor(i),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black45, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _note = _note.copyWith(pinColor: result);
      });
    }
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black54),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Icon(Icons.check,
                      color: AppColors.actionGreen, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black54),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _cancel,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Icon(Icons.close,
                      color: AppColors.actionRed, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
