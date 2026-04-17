import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/cork_background.dart';
import 'note_edit_screen.dart';

/// شاشة البحث في الملاحظات (كل الفئات)
class SearchScreen extends StatefulWidget {
  /// إذا كانت null فالبحث في كل الفئات، وإلا في الفئة المحددة
  final int? categoryIndex;
  const SearchScreen({super.key, this.categoryIndex});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _categoryColor(int index) {
    switch (index) {
      case 0:
        return AppColors.tabHome;
      case 1:
        return AppColors.tabWork;
      case 2:
        return AppColors.tabFamily;
      default:
        return AppColors.tabSettings;
    }
  }

  String _categoryName(int index) {
    switch (index) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'العمل';
      case 2:
        return 'العائلة';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CorkBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: Consumer<NotesService>(
                  builder: (_, service, __) {
                    final results = service.searchNotes(
                      _query,
                      categoryIndex: widget.categoryIndex,
                    );
                    if (_query.isEmpty) {
                      return _buildTipsView();
                    }
                    if (results.isEmpty) {
                      return _buildNoResultsView();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildResultTile(results[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black.withValues(alpha: 0.08),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide(color: Colors.black54)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black54),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'ابحث في ملاحظاتك...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 18, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.noteYellow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black38),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 48, color: Colors.brown),
              SizedBox(height: 10),
              Text(
                'اكتب كلمة أو جملة للبحث',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يمكنك البحث بمحتوى أي ملاحظة من أي فئة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.noteYellow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black38),
        ),
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.redAccent),
              SizedBox(height: 10),
              Text(
                'لم يتم العثور على نتائج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile(Note note) {
    final catName = _categoryName(note.categoryIndex);
    final catColor = _categoryColor(note.categoryIndex);
    final firstLine = note.content.split('\n').first.trim();
    final title = firstLine.isEmpty ? 'مسودة' : firstLine;
    final preview = note.content.length > 120
        ? '${note.content.substring(0, 120)}...'
        : note.content;

    return Material(
      color: AppColors.noteYellow,
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteEditScreen(note: note, isNew: false),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black38),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black38),
                      ),
                      child: Text(
                        catName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.relative(note.updatedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (preview != title) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
