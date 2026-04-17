import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../utils/haptics.dart';
import '../widgets/cork_background.dart';
import '../widgets/pushpin.dart';
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
  late Note _originalNote;
  late String _originalContent;
  bool _showFormatBar = false;
  bool _showOptionsMenu = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _originalNote = widget.note;
    _originalContent = _note.content;
    _controller = TextEditingController(text: _note.content);
    _controller.addListener(() {
      // إعادة بناء لتحديث حالة زر الحفظ أو مؤشر التغييرات
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// هل هناك تعديلات غير محفوظة؟
  bool get _hasUnsavedChanges {
    if (_controller.text != _originalContent) return true;
    if (_note.pinColor != _originalNote.pinColor) return true;
    if (_note.fontSize != _originalNote.fontSize) return true;
    if (_note.isBold != _originalNote.isBold) return true;
    if (_note.isItalic != _originalNote.isItalic) return true;
    if (_note.isUnderline != _originalNote.isUnderline) return true;
    if (_note.isStrikethrough != _originalNote.isStrikethrough) return true;
    if (_note.isHighlighted != _originalNote.isHighlighted) return true;
    if (_note.isReadOnly != _originalNote.isReadOnly) return true;
    if (_note.isPinnedToHome != _originalNote.isPinnedToHome) return true;
    if (_note.reminderDate != _originalNote.reminderDate) return true;
    if (_note.noteColor != _originalNote.noteColor) return true;
    return false;
  }

  /// عرض حوار تأكيد الخروج بدون حفظ
  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'تعديلات غير محفوظة',
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'لديك تعديلات لم يتم حفظها. هل تريد تجاهلها والخروج؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'تجاهل وخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    final service = context.read<NotesService>();
    final settings = context.read<SettingsService>();
    final updated = _note.copyWith(content: _controller.text);
    if (widget.isNew) {
      // لا نحفظ ملاحظة جديدة فارغة تمامًا
      if (updated.content.trim().isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pop(false);
        return;
      }
      await service.addNote(updated);
    } else {
      await service.updateNote(updated);
    }
    Haptics.light(settings);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _cancel() async {
    final ok = await _confirmDiscardChanges();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(false);
    }
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
            'تم تعيين تذكير ليوم ${DateFormatter.arabicDate(result)} الساعة ${DateFormatter.time12(result)}',
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
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await _confirmDiscardChanges();
        if (!mounted) return;
        if (ok) {
          navigator.pop(false);
        }
      },
      child: Scaffold(
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
            // زر الإطار العلوي يعرض الفئة الحالية (قابل للضغط للنقل)
            InkWell(
              onTap: _moveToCategory,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _categoryColor(_note.categoryIndex),
                      _categoryColor(_note.categoryIndex).withValues(alpha: 0.7),
                    ],
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
                    Icon(_categoryIcon(_note.categoryIndex), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _categoryName(_note.categoryIndex),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // زر الرجوع
            _smallRoundButton(
              icon: Icons.list,
              onTap: _cancel,
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

  IconData _categoryIcon(int index) {
    switch (index) {
      case 1:
        return Icons.work;
      case 2:
        return Icons.family_restroom;
      default:
        return Icons.push_pin;
    }
  }

  Color _categoryColor(int index) {
    switch (index) {
      case 1:
        return AppColors.tabWork;
      case 2:
        return AppColors.tabFamily;
      default:
        return AppColors.tabHome;
    }
  }

  Widget _buildNoteArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.noteColorPrimary(_note.noteColor),
                  AppColors.noteColorSecondary(_note.noteColor),
                ],
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
            // شارة التذكير إن وُجد
            if (_note.reminderDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade400),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Icon(Icons.alarm,
                            size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'تذكير: ${DateFormatter.reminderFull(_note.reminderDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _note = _note.copyWith(clearReminder: true);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حذف التذكير'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.close,
                                size: 16, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
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
          // دبوس التثبيت فوق الملاحظة - قابل للنقر لتغيير اللون
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _pickPinColor,
                child: Tooltip(
                  message: 'اضغط لتغيير لون الدبوس',
                  child: Pushpin(colorIndex: _note.pinColor, size: 34),
                ),
              ),
            ),
          ),
        ],
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
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.palette, 'لون ورقة الملاحظة', () {
                setState(() => _showOptionsMenu = false);
                _pickNoteColor();
              }),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.push_pin, 'لون الدبوس', () {
                setState(() => _showOptionsMenu = false);
                _pickPinColor();
              }),
              const Divider(height: 1, color: Colors.black26),
              _menuItem(Icons.folder_open, 'نقل إلى فئة أخرى', () {
                setState(() => _showOptionsMenu = false);
                _moveToCategory();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveToCategory() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'نقل الملاحظة إلى فئة',
          textDirection: TextDirection.rtl,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in const [
                [0, 'الرئيسية', Icons.push_pin],
                [1, 'العمل', Icons.work],
                [2, 'العائلة', Icons.family_restroom],
              ])
                ListTile(
                  leading: Icon(item[2] as IconData),
                  title: Text(item[1] as String),
                  trailing: _note.categoryIndex == item[0]
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => Navigator.of(context).pop(item[0] as int),
                ),
            ],
          ),
        ),
      ),
    );
    if (result != null && result != _note.categoryIndex) {
      setState(() {
        _note = _note.copyWith(categoryIndex: result);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم النقل إلى ${_categoryName(result)}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
              icon: Icons.palette,
              active: false,
              onTap: _pickNoteColor,
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

  Future<void> _pickNoteColor() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'اختر لون الملاحظة',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 300,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (int i = 0; i < AppColors.noteColors.length; i++)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(i),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.noteColorPrimary(i),
                            AppColors.noteColorSecondary(i),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _note.noteColor == i
                              ? Colors.blue.shade700
                              : Colors.black26,
                          width: _note.noteColor == i ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_note.noteColor == i)
                              const Icon(Icons.check_circle,
                                  color: Colors.black87, size: 20),
                            const SizedBox(height: 4),
                            Text(
                              AppColors.noteColorNames[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _note = _note.copyWith(noteColor: result);
      });
    }
  }

  Future<void> _pickPinColor() async {
    final pinNames = AppColors.pinNames;
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text(
          'اختر لون الدبوس',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: 260,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (int i = 0; i < 4; i++)
                  InkWell(
                    onTap: () => Navigator.of(context).pop(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 96,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _note.pinColor == i
                              ? AppColors.pinColor(i)
                              : Colors.black26,
                          width: _note.pinColor == i ? 2.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Pushpin(colorIndex: i, size: 32),
                          const SizedBox(height: 6),
                          Text(
                            pinNames[i],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
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
