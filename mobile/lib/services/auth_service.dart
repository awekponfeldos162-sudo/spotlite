import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);

    if (res.user == null)
      throw Exception('Erreur lors de la création du compte');
    final uid = res.user!.id;

    await _client.from('profiles').insert({
      'id': uid,
      'email': email,
      'type_utilisateur': role.name == 'talent' ? 'talent' : 'employeur',
    });

    if (role == UserRole.talent) {
      await _client.from('talents').insert({
        'profile_id': uid,
        'nom': fullName,
      });
    } else {
      await _client.from('employers').insert({
        'profile_id': uid,
        'nom_entreprise': fullName,
      });
    }

    // ✅ Connexion automatique après inscription
    await _client.auth.signInWithPassword(email: email, password: password);

    return UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  Future<void> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) throw Exception('Email ou mot de passe incorrect');
  }

  Future<void> signOut() async => await _client.auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;

    String fullName = '';
    final type = data['type_utilisateur'];

    if (type == 'talent') {
      final talent = await _client
          .from('talents')
          .select('nom')
          .eq('profile_id', uid)
          .maybeSingle();
      fullName = talent?['nom'] ?? '';
    } else {
      final employer = await _client
          .from('employers')
          .select('nom_entreprise')
          .eq('profile_id', uid)
          .maybeSingle();
      fullName = employer?['nom_entreprise'] ?? '';
    }

    return UserModel(
      id: data['id'],
      email: data['email'],
      fullName: fullName,
      // ✅ Correction : 'employeur' pas 'employer'
      role: type == 'talent' ? UserRole.talent : UserRole.employer,
      createdAt: DateTime.parse(data['date_creation']),
    );
  }
}
