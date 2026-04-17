/// نموذج الملاحظة - يمثل ملاحظة لاصقة واحدة على اللوحة
class Note {
  String id;
  String title;
  String content;
  int categoryIndex; // 0: الرئيسية, 1: العمل, 2: العائلة
  int pinColor; // 0: أخضر, 1: أحمر, 2: أزرق, 3: أصفر
  int noteColor; // 0: أصفر, 1: وردي, 2: أخضر, 3: أزرق, 4: برتقالي, 5: أبيض
  double fontSize;
  bool isBold;
  bool isItalic;
  bool isUnderline;
  bool isStrikethrough;
  bool isHighlighted;
  bool isReadOnly;
  bool isPinnedToHome;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? reminderDate;
  int positionX; // ترتيب الموضع في الشبكة
  int positionY;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.categoryIndex = 0,
    this.pinColor = 0,
    this.noteColor = 0,
    this.fontSize = 14.0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.isHighlighted = false,
    this.isReadOnly = false,
    this.isPinnedToHome = false,
    required this.createdAt,
    required this.updatedAt,
    this.reminderDate,
    this.positionX = 0,
    this.positionY = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryIndex': categoryIndex,
      'pinColor': pinColor,
      'noteColor': noteColor,
      'fontSize': fontSize,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'isStrikethrough': isStrikethrough,
      'isHighlighted': isHighlighted,
      'isReadOnly': isReadOnly,
      'isPinnedToHome': isPinnedToHome,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'reminderDate': reminderDate?.millisecondsSinceEpoch,
      'positionX': positionX,
      'positionY': positionY,
    };
  }

  factory Note.fromMap(Map<dynamic, dynamic> map) {
    return Note(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      categoryIndex: (map['categoryIndex'] ?? 0) as int,
      pinColor: (map['pinColor'] ?? 0) as int,
      noteColor: (map['noteColor'] ?? 0) as int,
      fontSize: (map['fontSize'] ?? 14.0).toDouble(),
      isBold: (map['isBold'] ?? false) as bool,
      isItalic: (map['isItalic'] ?? false) as bool,
      isUnderline: (map['isUnderline'] ?? false) as bool,
      isStrikethrough: (map['isStrikethrough'] ?? false) as bool,
      isHighlighted: (map['isHighlighted'] ?? false) as bool,
      isReadOnly: (map['isReadOnly'] ?? false) as bool,
      isPinnedToHome: (map['isPinnedToHome'] ?? false) as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch) as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch) as int),
      reminderDate: map['reminderDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderDate'] as int)
          : null,
      positionX: (map['positionX'] ?? 0) as int,
      positionY: (map['positionY'] ?? 0) as int,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? categoryIndex,
    int? pinColor,
    int? noteColor,
    double? fontSize,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isStrikethrough,
    bool? isHighlighted,
    bool? isReadOnly,
    bool? isPinnedToHome,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reminderDate,
    bool clearReminder = false,
    int? positionX,
    int? positionY,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      pinColor: pinColor ?? this.pinColor,
      noteColor: noteColor ?? this.noteColor,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isPinnedToHome: isPinnedToHome ?? this.isPinnedToHome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderDate: clearReminder ? null : (reminderDate ?? this.reminderDate),
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }
}
