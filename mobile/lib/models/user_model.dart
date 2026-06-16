enum UserRole { talent, employer }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? sector;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.sector,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'] ?? '',
      // ✅ Gérer 'employeur' ET 'employer'
      role: map['type_utilisateur'] == 'talent'
          ? UserRole.talent
          : UserRole.employer,
      avatarUrl: map['avatar_url'],
      sector: map['sector'],
      createdAt: DateTime.parse(map['date_creation'] ?? map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    // ✅ Toujours stocker 'employeur' en français pour Supabase
    'type_utilisateur': role == UserRole.talent ? 'talent' : 'employeur',
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };
}
