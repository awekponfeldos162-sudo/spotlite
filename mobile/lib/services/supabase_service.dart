import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/talent_model.dart';
import '../models/employer_model.dart';
import '../models/match_model.dart';

class SupabaseService {
  final _db = Supabase.instance.client;

  // ── TALENTS ──────────────────────────────────
  Future<TalentModel?> getTalentByProfileId(String profileId) async {
    final data = await _db
        .from('talents')
        .select('*, skills(*)')
        .eq('profile_id', profileId)
        .maybeSingle();
    return data != null ? TalentModel.fromMap(data) : null;
  }

  Future<List<TalentModel>> getTalents({String? secteur}) async {
    dynamic query = _db
        .from('talents')
        .select('*, skills(*)')
        .eq('statut_recherche', 'disponible');
    if (secteur != null) {
      query = query.eq('secteur', secteur);
    }
    query = query.order('score_qualification', ascending: false);
    final data = await query;
    return (data as List).map((e) => TalentModel.fromMap(e)).toList();
  }

  Future<void> updateTalent(String id, Map<String, dynamic> updates) async {
    await _db.from('talents').update(updates).eq('id', id);
  }

  // ── SKILLS ───────────────────────────────────
  Future<void> addSkill(Map<String, dynamic> skill) async {
    await _db.from('skills').insert(skill);
  }

  Future<void> deleteSkill(String skillId) async {
    await _db.from('skills').delete().eq('id', skillId);
  }

  // ── EMPLOYERS ────────────────────────────────
  Future<EmployerModel?> getEmployerByProfileId(String profileId) async {
    final data = await _db
        .from('employers')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();
    return data != null ? EmployerModel.fromMap(data) : null;
  }

  // ── MATCHES ──────────────────────────────────
  Future<List<MatchModel>> getMatchesForTalent(String talentId) async {
    final data = await _db
        .from('matches')
        .select('*, employers(*)')
        .eq('talent_id', talentId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => MatchModel.fromMap(e)).toList();
  }

  Future<List<MatchModel>> getMatchesForEmployer(String employerId) async {
    final data = await _db
        .from('matches')
        .select('*, talents(*, skills(*))')
        .eq('employer_id', employerId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => MatchModel.fromMap(e)).toList();
  }

  Future<void> createMatch({
    required String talentId,
    required String employerId,
    required String initiedPar,
  }) async {
    await _db.from('matches').upsert({
      'talent_id': talentId,
      'employer_id': employerId,
      'initie_par': initiedPar,
      if (initiedPar == 'talent') 'talent_like': true,
      if (initiedPar == 'employeur') 'employer_like': true,
    });
  }

  Future<void> respondToMatch(
    String matchId,
    bool accepted,
    String role,
  ) async {
    final update = role == 'talent'
        ? {'talent_like': accepted}
        : {'employer_like': accepted};

    final match = await _db.from('matches').select().eq('id', matchId).single();
    final talentLike = role == 'talent'
        ? accepted
        : (match['talent_like'] ?? false);
    final employerLike = role == 'employeur'
        ? accepted
        : (match['employer_like'] ?? false);

    final statut = !accepted
        ? 'rejected'
        : (talentLike && employerLike ? 'accepted' : 'pending');

    await _db
        .from('matches')
        .update({...update, 'statut': statut})
        .eq('id', matchId);
  }

  // ── NOTIFICATIONS REALTIME ────────────────────
  RealtimeChannel listenToNotifications(
    String userId,
    void Function(Map<String, dynamic>) onNotification,
  ) {
    return _db
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onNotification(payload.newRecord),
        )
        .subscribe();
  }
}
