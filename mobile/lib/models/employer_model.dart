class EmployerModel {
  final String id;
  final String profileId;
  final String nomEntreprise;
  final String? secteur;
  final String? taille;
  final String? description;
  final String? logoUrl;
  final String? localisation;
  final bool verified;

  EmployerModel({
    required this.id,
    required this.profileId,
    required this.nomEntreprise,
    this.secteur,
    this.taille,
    this.description,
    this.logoUrl,
    this.localisation,
    required this.verified,
  });

  factory EmployerModel.fromMap(Map<String, dynamic> map) => EmployerModel(
    id: map['id'],
    profileId: map['profile_id'],
    nomEntreprise: map['nom_entreprise'],
    secteur: map['secteur'],
    taille: map['taille'],
    description: map['description'],
    logoUrl: map['logo_url'],
    localisation: map['localisation'],
    verified: map['verified'] ?? false,
  );
}
