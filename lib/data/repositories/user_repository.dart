import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('streak', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList();
    });
  }
}
