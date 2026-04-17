import 'package:flutter_test/flutter_test.dart';
import 'package:cork_board_notes/models/note.dart';

void main() {
  test('Note model serialization round trip', () {
    final now = DateTime.now();
    final note = Note(
      id: 'abc',
      content: 'test',
      categoryIndex: 1,
      pinColor: 2,
      createdAt: now,
      updatedAt: now,
      isBold: true,
    );
    final map = note.toMap();
    final restored = Note.fromMap(map);
    expect(restored.id, 'abc');
    expect(restored.content, 'test');
    expect(restored.categoryIndex, 1);
    expect(restored.pinColor, 2);
    expect(restored.isBold, true);
  });

  test('Note copyWith preserves values', () {
    final now = DateTime.now();
    final note = Note(
      id: 'x',
      createdAt: now,
      updatedAt: now,
    );
    final updated = note.copyWith(content: 'hello', isItalic: true);
    expect(updated.content, 'hello');
    expect(updated.isItalic, true);
    expect(updated.id, 'x');
  });
}
