import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usage_model.dart';

class UsageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ScreenTimeData>> getUsageStats() {
    return _firestore
        .collection('usage_stats')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ScreenTimeData.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> seedUsageDataIfEmpty() async {
    final snapshot = await _firestore.collection('usage_stats').limit(1).get();
    if (snapshot.docs.isEmpty) {
      final data = [
        {'day': 'Пн', 'minutes': 120, 'category': 'Instagram'},
        {'day': 'Вт', 'minutes': 145, 'category': 'TikTok'},
        {'day': 'Ср', 'minutes': 60, 'category': 'YouTube'},
        {'day': 'Чт', 'minutes': 110, 'category': 'Instagram'},
        {'day': 'Пт', 'minutes': 180, 'category': 'TikTok'},
        {'day': 'Сб', 'minutes': 210, 'category': 'Games'},
        {'day': 'Вс', 'minutes': 145, 'category': 'YouTube'},
      ];
      for (var item in data) {
        await _firestore.collection('usage_stats').add(item);
      }
    }
  }
}
