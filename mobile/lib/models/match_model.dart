enum MatchStatus { pending, matched, rejected }

class MatchModel {
  final String id;
  final String talentId;
  final String employerId;
  final bool talentLiked;
  final bool employerLiked;
  final MatchStatus status;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.talentId,
    required this.employerId,
    required this.talentLiked,
    required this.employerLiked,
    required this.status,
    required this.createdAt,
  });

  bool get isMatch => talentLiked && employerLiked;

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'],
      talentId: map['talent_id'],
      employerId: map['employer_id'],
      talentLiked: map['talent_liked'] ?? false,
      employerLiked: map['employer_liked'] ?? false,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.pending,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
