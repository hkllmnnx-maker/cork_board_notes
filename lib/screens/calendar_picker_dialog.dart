import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// منتقي التاريخ العربي بتصميم مخصص مثل الصورة المرجعية
class ArabicCalendarDialog extends StatefulWidget {
  final DateTime? initialDate;
  const ArabicCalendarDialog({super.key, this.initialDate});

  @override
  State<ArabicCalendarDialog> createState() => _ArabicCalendarDialogState();
}

class _ArabicCalendarDialogState extends State<ArabicCalendarDialog> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  // ترتيب الأيام: الأحد -> السبت (حسب الصورة المرجعية)
  static const List<String> _weekDays = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<DateTime> _buildDays() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    // weekday حسب DateTime: الاثنين=1 ... الأحد=7
    // نريد أن يكون الأحد هو أول يوم (offset 0)
    final weekday = firstDayOfMonth.weekday; // 1..7
    final offset = weekday % 7; // الأحد(7)=0, الاثنين(1)=1, ... السبت(6)=6
    final startDate = firstDayOfMonth.subtract(Duration(days: offset));
    return List.generate(42, (i) => startDate.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              const Divider(color: Colors.black38, height: 1),
              const SizedBox(height: 8),
              _buildWeekDaysHeader(),
              const SizedBox(height: 4),
              _buildCalendarGrid(),
              const SizedBox(height: 8),
              _buildSelectedDateLabel(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _roundIconButton(Icons.chevron_right, _prevMonth),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black54, width: 1),
              ),
              child: Text(
                '${_arabicMonths[_displayedMonth.month - 1]}  ${_displayedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        _roundIconButton(Icons.chevron_left, _nextMonth),
      ],
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black54),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                _weekDays[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: (i == 0 || i == 5 || i == 6)
                      ? Colors.red.shade700
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final days = _buildDays();
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          for (int row = 0; row < 6; row++)
            Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(child: _buildDayCell(days[row * 7 + col], col)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, int col) {
    final isInMonth = date.month == _displayedMonth.month;
    final isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
    final isWeekend = col == 0 || col == 5 || col == 6;

    Color textColor;
    if (!isInMonth) {
      textColor = Colors.grey.shade400;
    } else if (isWeekend) {
      textColor = Colors.red.shade700;
    } else {
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade400 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.black12,
            width: 0.5,
            style: isInMonth ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade400, width: 1.2),
      ),
      child: Text(
        '${_selectedDate.day} ${_arabicMonths[_selectedDate.month - 1]} ${_selectedDate.year}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // تأكيد
        _actionButton(
          icon: Icons.check,
          color: AppColors.actionGreen,
          onTap: () => Navigator.of(context).pop(_selectedDate),
        ),
        // اليوم (إعادة ضبط)
        _actionButton(
          icon: Icons.calendar_today,
          color: Colors.black87,
          onTap: () {
            setState(() {
              _selectedDate = DateTime.now();
              _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
            });
          },
        ),
        // إلغاء
        _actionButton(
          icon: Icons.close,
          color: AppColors.actionRed,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black26, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
