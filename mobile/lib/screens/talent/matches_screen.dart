import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/matching_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/match_model.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talentAsync = ref.watch(talentProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mes Matches',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: talentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (talent) {
          if (talent == null)
            return const Center(child: Text('Profil introuvable'));
          final matchesAsync = ref.watch(talentMatchesProvider(talent.id));
          return matchesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (matches) {
              if (matches.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'Aucun match pour le moment',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return _MatchTile(match: match);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchModel match;
  const _MatchTile({required this.match});

  Color get _statusColor => switch (match.status) {
    MatchStatus.matched => const Color(0xFFFFD700),
    MatchStatus.rejected => Colors.red,
    _ => Colors.white38,
  };

  String get _statusLabel => switch (match.status) {
    MatchStatus.matched => '✅ Match !',
    MatchStatus.rejected => '❌ Refusé',
    _ => '⏳ En attente',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: _statusColor, width: 1.5),
            ),
            child: const Icon(Icons.business, color: Colors.white54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entreprise',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  match.createdAt.toString().substring(0, 10),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
