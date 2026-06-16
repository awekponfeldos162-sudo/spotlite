import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  return ref.read(authServiceProvider).getCurrentUser();
});
