import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'settings_service.dart';

/// خدمة إدارة الملاحظات باستخدام Hive للتخزين المحلي
class NotesService extends ChangeNotifier {
  static const String _boxName = 'notes_box';
  late Box _box;
  final List<Note> _notes = [];
  final Uuid _uuid = const Uuid();

  List<Note> get notes => _notes;

  /// ترتيب الفرز الحالي (يُضبط من SettingsService عند الحاجة)
  NoteSortOrder _sortOrder = NoteSortOrder.updatedDesc;
  NoteSortOrder get sortOrder => _sortOrder;

  void setSortOrder(NoteSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    notifyListeners();
  }

  /// تطبيق الترتيب الحالي على قائمة
  void _applySort(List<Note> list) {
    switch (_sortOrder) {
      case NoteSortOrder.updatedDesc:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOrder.updatedAsc:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortOrder.createdDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOrder.createdAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOrder.alphabetical:
        list.sort((a, b) => a.content
            .trim()
            .toLowerCase()
            .compareTo(b.content.trim().toLowerCase()));
        break;
    }
  }

  /// الملاحظات حسب الفئة
  List<Note> notesByCategory(int categoryIndex) {
    final list =
        _notes.where((n) => n.categoryIndex == categoryIndex).toList();
    _applySort(list);
    return list;
  }

  /// البحث في الملاحظات (بنص معيّن، مع إمكانية التقييد بفئة)
  List<Note> searchNotes(String query, {int? categoryIndex}) {
    final q = query.trim().toLowerCase();
    Iterable<Note> source = _notes;
    if (categoryIndex != null) {
      source = source.where((n) => n.categoryIndex == categoryIndex);
    }
    if (q.isNotEmpty) {
      source = source.where((n) =>
          n.content.toLowerCase().contains(q) ||
          n.title.toLowerCase().contains(q));
    }
    final results = source.toList();
    _applySort(results);
    return results;
  }

  /// الملاحظات المثبتة على الشاشة الرئيسية
  List<Note> get pinnedNotes {
    final list = _notes.where((n) => n.isPinnedToHome).toList();
    _applySort(list);
    return list;
  }

  /// الملاحظات ذات التذكيرات القادمة
  List<Note> get upcomingReminders {
    final now = DateTime.now();
    return _notes
        .where((n) =>
            n.reminderDate != null && !n.reminderDate!.isBefore(now))
        .toList()
      ..sort((a, b) => a.reminderDate!.compareTo(b.reminderDate!));
  }

  /// تهيئة Hive وتحميل الملاحظات
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    await _loadNotes();

    // إضافة ملاحظات افتراضية إذا كان التطبيق فارغًا لأول مرة
    if (_notes.isEmpty) {
      await _seedDefaultNotes();
    }
  }

  Future<void> _loadNotes() async {
    _notes.clear();
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data is Map) {
        try {
          _notes.add(Note.fromMap(data));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error loading note: $e');
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> _seedDefaultNotes() async {
    final now = DateTime.now();
    final samples = [
      Note(
        id: _uuid.v4(),
        content: 'مرحبًا بك في ملاحظاتي\nاضغط على + لإضافة ملاحظة جديدة',
        categoryIndex: 0,
        pinColor: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Note(
        id: _uuid.v4(),
        content: 'اجتماع مع الفريق يوم الأحد الساعة 10 صباحًا',
        categoryIndex: 1,
        pinColor: 1,
        isBold: true,
        createdAt: now,
        updatedAt: now,
      ),
      Note(
        id: _uuid.v4(),
        content: 'شراء الخضروات والفواكه من السوق',
        categoryIndex: 2,
        pinColor: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Note(
        id: _uuid.v4(),
        content: 'قائمة المهام:\n- قراءة كتاب\n- ممارسة الرياضة\n- مراجعة البريد',
        categoryIndex: 0,
        pinColor: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final n in samples) {
      await addNote(n);
    }
  }

  Future<Note> createNewNote({int categoryIndex = 0}) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      content: '',
      categoryIndex: categoryIndex,
      pinColor: 0,
      createdAt: now,
      updatedAt: now,
    );
    return note;
  }

  Future<void> addNote(Note note) async {
    await _box.put(note.id, note.toMap());
    _notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _box.put(updated.id, updated.toMap());
    final idx = _notes.indexWhere((n) => n.id == updated.id);
    if (idx >= 0) {
      _notes[idx] = updated;
    } else {
      _notes.add(updated);
    }
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<Note> duplicateNote(Note note) async {
    final now = DateTime.now();
    final copy = note.copyWith(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
    );
    await addNote(copy);
    return copy;
  }

  /// حذف كل الملاحظات دفعة واحدة (أسرع من الحذف فرديًا)
  Future<void> clearAll() async {
    await _box.clear();
    _notes.clear();
    notifyListeners();
  }
}
