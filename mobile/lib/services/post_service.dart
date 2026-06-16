import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final _db = Supabase.instance.client;

  // Stream temps réel du feed
  Stream<List<Map<String, dynamic>>> feedStream() {
    return _db
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows);
  }

  // Récupérer les infos du créateur du post
  Future<Map<String, dynamic>> getPostAuthor(String profileId) async {
    final profile = await _db
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single();

    String nom = '';
    String titre = '';
    int score = 0;
    String? avatarUrl = profile['avatar_url'];

    if (profile['type_utilisateur'] == 'talent') {
      final talent = await _db
          .from('talents')
          .select('nom, titre, score_qualification')
          .eq('profile_id', profileId)
          .maybeSingle();
      nom = talent?['nom'] ?? '';
      titre = talent?['titre'] ?? 'Talent Spotlite';
      score = talent?['score_qualification'] ?? 0;
    } else {
      final employer = await _db
          .from('employers')
          .select('nom_entreprise, logo_url')
          .eq('profile_id', profileId)
          .maybeSingle();
      nom = employer?['nom_entreprise'] ?? '';
      titre = 'Entreprise';
      avatarUrl = employer?['logo_url'] ?? avatarUrl;
    }

    return {
      'nom': nom,
      'titre': titre,
      'score': score,
      'avatar': avatarUrl,
      'type': profile['type_utilisateur'],
    };
  }

  // Créer un post
  Future<void> createPost({
    required String profileId,
    required String content,
    String? mediaUrl,
    String mediaType = 'none',
    List<String> hashtags = const [],
  }) async {
    await _db.from('posts').insert({
      'profile_id': profileId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'hashtags': hashtags,
    });
  }

  // Toggle like
  Future<bool> toggleLike(String postId, String userId) async {
    final result = await _db.rpc(
      'toggle_like',
      params: {'p_post_id': postId, 'p_user_id': userId},
    );
    return result as bool;
  }

  // Vérifier si l'utilisateur a liké
  Future<bool> hasLiked(String postId, String userId) async {
    final data = await _db
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  // Stream commentaires d'un post
  Stream<List<Map<String, dynamic>>> commentsStream(String postId) {
    return _db
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((rows) => rows);
  }

  // Ajouter un commentaire
  Future<void> addComment(String postId, String userId, String content) async {
    await _db.from('comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
  }

  // Flasher un talent (employeur uniquement)
  Future<void> flashTalent({
    required String talentProfileId,
    required String employerProfileId,
  }) async {
    // 1. Récupérer les IDs talent et employer
    final talent = await _db
        .from('talents')
        .select('id')
        .eq('profile_id', talentProfileId)
        .single();

    final employer = await _db
        .from('employers')
        .select('id, nom_entreprise')
        .eq('profile_id', employerProfileId)
        .single();

    // 2. Créer le match
    await _db.from('matches').upsert({
      'talent_id': talent['id'],
      'employer_id': employer['id'],
      'initie_par': 'employeur',
      'employer_like': true,
    });

    // 3. Envoyer notification temps réel au talent
    await _db.from('notifications').insert({
      'user_id': talentProfileId,
      'type': 'profil_vu',
      'titre': '⚡ Vous avez été flashé !',
      'corps': '${employer['nom_entreprise']} souhaite vous contacter !',
      'data': {'employer_id': employer['id']},
    });
  }

  // Posts d'un profil spécifique
  Future<List<Map<String, dynamic>>> getProfilePosts(String profileId) async {
    return await _db
        .from('posts')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);
  }
}
