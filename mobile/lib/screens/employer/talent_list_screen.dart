import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/matching_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/profile_card.dart';
import '../../services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentListScreen extends ConsumerStatefulWidget {
  const TalentListScreen({super.key});
  @override
  ConsumerState<TalentListScreen> createState() => _TalentListScreenState();
}

class _TalentListScreenState extends ConsumerState<TalentListScreen> {
  String? _secteurFiltre;
  final List<String> _secteurs = [
    'Tous',
    'Tech',
    'Créatif',
    'Finance',
    'Marketing',
    'RH',
  ];

  @override
  Widget build(BuildContext context) {
    final employerAsync = ref.watch(employerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Talents',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: employerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (employer) {
          if (employer == null) return const SizedBox();
          final talentsAsync = ref.watch(employerTalentsProvider(employer.id));
          return Column(
            children: [
              // Filtres
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _secteurs.length,
                  itemBuilder: (context, i) {
                    final s = _secteurs[i];
                    final selected =
                        (s == 'Tous' && _secteurFiltre == null) ||
                        s == _secteurFiltre;
                    return GestureDetector(
                      onTap: () => setState(
                        () => _secteurFiltre = s == 'Tous' ? null : s,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(
                          right: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            s,
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.white54,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Liste
              Expanded(
                child: talentsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  ),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (talents) {
                    final filtered = _secteurFiltre == null
                        ? talents
                        : talents
                              .where((t) => t.secteur == _secteurFiltre)
                              .toList();
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => ProfileCard(
                        talent: filtered[i],
                        onLike: () async {
                          await ref
                              .read(Provider((r) => SupabaseService()))
                              .createMatch(
                                talentId: filtered[i].id,
                                employerId: employer.id,
                                initiedPar: 'employeur',
                              );
                        },
                        onPass: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
