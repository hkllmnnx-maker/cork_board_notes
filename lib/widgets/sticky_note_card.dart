import 'dart:math';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/app_colors.dart';
import 'pushpin.dart';

/// كرت الملاحظة اللاصقة يظهر في الشبكة
class StickyNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const StickyNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // ميلان بسيط يعتمد على hash للـ id لإعطاء شكل طبيعي
    final seed = note.id.hashCode;
    final random = Random(seed);
    final rotation = (random.nextDouble() - 0.5) * 0.04; // ~±1.1 درجة
    final hasContent = note.content.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Transform.rotate(
        angle: rotation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // جسم الملاحظة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.noteColorPrimary(note.noteColor),
                    AppColors.noteColorSecondary(note.noteColor),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
              child: hasContent
                  ? Text(
                      note.content,
                      textDirection: TextDirection.rtl,
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.35,
                        fontWeight:
                            note.isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            note.isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: _buildDecoration(),
                        backgroundColor: note.isHighlighted
                            ? Colors.yellow.shade600.withValues(alpha: 0.6)
                            : null,
                      ),
                    )
                  : Center(
                      child: Text(
                        'مسودة',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.brown.withValues(alpha: 0.35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            // الدبوس
            Positioned(
              top: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Pushpin(colorIndex: note.pinColor, size: 20),
              ),
            ),
            // مؤشر التذكير (إن وُجد)
            if (note.reminderDate != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            // مؤشر التثبيت في الرئيسية
            if (note.isPinnedToHome)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextDecoration _buildDecoration() {
    final list = <TextDecoration>[];
    if (note.isUnderline) list.add(TextDecoration.underline);
    if (note.isStrikethrough) list.add(TextDecoration.lineThrough);
    if (list.isEmpty) return TextDecoration.none;
    if (list.length == 1) return list.first;
    return TextDecoration.combine(list);
  }
}
