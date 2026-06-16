import 'skill_model.dart';

class TalentModel {
  final String id;
  final String profileId;
  final String nom;
  final String? titre;
  final String? biographie;
  final String? secteur;
  final String? localisation;
  final String statutRecherche;
  final int scoreQualification;
  final List<SkillModel> skills;

  TalentModel({
    required this.id,
    required this.profileId,
    required this.nom,
    this.titre,
    this.biographie,
    this.secteur,
    this.localisation,
    required this.statutRecherche,
    required this.scoreQualification,
    this.skills = const [],
  });

  factory TalentModel.fromMap(Map<String, dynamic> map) => TalentModel(
    id: map['id'],
    profileId: map['profile_id'],
    nom: map['nom'],
    titre: map['titre'],
    biographie: map['biographie'],
    secteur: map['secteur'],
    localisation: map['localisation'],
    statutRecherche: map['statut_recherche'] ?? 'disponible',
    scoreQualification: map['score_qualification'] ?? 0,
    skills: (map['skills'] as List<dynamic>? ?? [])
        .map((s) => SkillModel.fromMap(s))
        .toList(),
  );
}
