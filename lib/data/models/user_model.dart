class UserModel {
  final String id;
  final String name;
  final int streak;
  final int age;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.streak,
    required this.age,
    required this.isActive,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'Аноним',
      streak: data['streak'] ?? 0,
      age: data['age'] ?? 25,
      isActive: data['isActive'] ?? true,
    );
  }
}
