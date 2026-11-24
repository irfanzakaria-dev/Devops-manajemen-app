class ReminderItem {
  final int id;
  final String title;
  final String description;
  int hour;
  int minute;
  bool isEnabled;
  final String category;
  final String daysSummary;

  ReminderItem({
    required this.id,
    required this.title,
    required this.description,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    required this.category,
    this.daysSummary = 'Setiap Hari Kerja (Sen - Jum)',
  });

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }
}
