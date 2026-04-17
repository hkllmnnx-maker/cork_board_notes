import 'package:flutter_test/flutter_test.dart';
import 'package:cork_board_notes/models/note.dart';

void main() {
  group('Note model', () {
    test('Note serialization round trip preserves all fields', () {
      final now = DateTime.now();
      final reminder = now.add(const Duration(days: 3));
      final note = Note(
        id: 'abc',
        title: 'title',
        content: 'test content',
        categoryIndex: 1,
        pinColor: 2,
        fontSize: 18.0,
        isBold: true,
        isItalic: true,
        isUnderline: true,
        isStrikethrough: true,
        isHighlighted: true,
        isReadOnly: true,
        isPinnedToHome: true,
        createdAt: now,
        updatedAt: now,
        reminderDate: reminder,
        positionX: 3,
        positionY: 4,
      );
      final restored = Note.fromMap(note.toMap());
      expect(restored.id, 'abc');
      expect(restored.title, 'title');
      expect(restored.content, 'test content');
      expect(restored.categoryIndex, 1);
      expect(restored.pinColor, 2);
      expect(restored.fontSize, 18.0);
      expect(restored.isBold, true);
      expect(restored.isItalic, true);
      expect(restored.isUnderline, true);
      expect(restored.isStrikethrough, true);
      expect(restored.isHighlighted, true);
      expect(restored.isReadOnly, true);
      expect(restored.isPinnedToHome, true);
      expect(restored.reminderDate!.millisecondsSinceEpoch,
          reminder.millisecondsSinceEpoch);
      expect(restored.positionX, 3);
      expect(restored.positionY, 4);
    });

    test('Note copyWith preserves untouched values', () {
      final now = DateTime.now();
      final note = Note(
        id: 'x',
        content: 'original',
        pinColor: 1,
        createdAt: now,
        updatedAt: now,
      );
      final updated = note.copyWith(content: 'hello', isItalic: true);
      expect(updated.content, 'hello');
      expect(updated.isItalic, true);
      expect(updated.id, 'x');
      expect(updated.pinColor, 1);
    });

    test('Note copyWith can clear reminder', () {
      final now = DateTime.now();
      final note = Note(
        id: 'x',
        createdAt: now,
        updatedAt: now,
        reminderDate: now.add(const Duration(days: 1)),
      );
      final cleared = note.copyWith(clearReminder: true);
      expect(cleared.reminderDate, isNull);
    });

    test('Note fromMap handles missing fields safely', () {
      final map = {'id': 'minimal', 'content': 'x'};
      final note = Note.fromMap(map);
      expect(note.id, 'minimal');
      expect(note.content, 'x');
      expect(note.categoryIndex, 0);
      expect(note.pinColor, 0);
      expect(note.fontSize, 14.0);
      expect(note.isBold, false);
      expect(note.isPinnedToHome, false);
      expect(note.reminderDate, isNull);
    });
  });
}
