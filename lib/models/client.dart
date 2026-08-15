class Client {
  const Client({
    this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.height,
    required this.weight,
    required this.injuries,
    required this.dietNotes,
    required this.fitnessGoal,
    required this.paymentDate,
    required this.membershipEndDate,
    this.photoPath,
  });

  final int? id;
  final String name;
  final String phone;
  final int age;
  final double height;
  final double weight;
  final String injuries;
  final String dietNotes;
  final String fitnessGoal;
  final DateTime paymentDate;
  final DateTime membershipEndDate;
  final String? photoPath;

  bool get membershipActive =>
      !membershipEndDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0));

  Client copyWith({int? id}) => Client(
        id: id ?? this.id,
        name: name,
        phone: phone,
        age: age,
        height: height,
        weight: weight,
        injuries: injuries,
        dietNotes: dietNotes,
        fitnessGoal: fitnessGoal,
        paymentDate: paymentDate,
        membershipEndDate: membershipEndDate,
        photoPath: photoPath,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'age': age,
        'height': height,
        'weight': weight,
        'injuries': injuries,
        'diet_notes': dietNotes,
        'fitness_goal': fitnessGoal,
        'payment_date': paymentDate.toIso8601String(),
        'membership_end_date': membershipEndDate.toIso8601String(),
        'photo_path': photoPath,
      };

  factory Client.fromMap(Map<String, Object?> map) => Client(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String,
        age: map['age'] as int,
        height: (map['height'] as num).toDouble(),
        weight: (map['weight'] as num).toDouble(),
        injuries: map['injuries'] as String,
        dietNotes: map['diet_notes'] as String,
        fitnessGoal: map['fitness_goal'] as String,
        paymentDate: DateTime.parse(map['payment_date'] as String),
        membershipEndDate:
            DateTime.parse(map['membership_end_date'] as String),
        photoPath: map['photo_path'] as String?,
      );
}
