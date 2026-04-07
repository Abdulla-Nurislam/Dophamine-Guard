class ScreenTimeData {
  final String id;
  final String day;
  final int minutes;
  final String category;

  ScreenTimeData({
    required this.id,
    required this.day,
    required this.minutes,
    required this.category,
  });

  factory ScreenTimeData.fromMap(String id, Map<String, dynamic> data) {
    return ScreenTimeData(
      id: id,
      day: data['day'] ?? '',
      minutes: data['minutes'] ?? 0,
      category: data['category'] ?? 'General',
    );
  }
}
