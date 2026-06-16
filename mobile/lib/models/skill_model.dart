class SkillModel {
  final String id;
  final String talentId;
  final String nom;
  final String niveau;
  final bool isVerified;

  SkillModel({
    required this.id,
    required this.talentId,
    required this.nom,
    required this.niveau,
    required this.isVerified,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map) => SkillModel(
    id: map['id'],
    talentId: map['talent_id'],
    nom: map['nom'],
    niveau: map['niveau'] ?? 'débutant',
    isVerified: map['is_verified'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'talent_id': talentId,
    'nom': nom,
    'niveau': niveau,
    'is_verified': isVerified,
  };
}
