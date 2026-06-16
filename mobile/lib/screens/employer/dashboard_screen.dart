import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/matching_provider.dart';
import '../../widgets/profile_card.dart';
import '../../services/supabase_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employerAsync = ref.watch(employerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SPOTLITE',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: employerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (employer) {
          if (employer == null) {
            return const Center(
              child: Text(
                'Profil employeur introuvable',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final talentsAsync = ref.watch(employerTalentsProvider(employer.id));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${employer.nomEntreprise} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Découvrez les talents du jour',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: talentsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  ),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (talents) {
                    if (talents.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun talent disponible pour le moment',
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: talents.length,
                      itemBuilder: (context, i) => ProfileCard(
                        talent: talents[i],
                        onLike: () async {
                          await ref
                              .read(Provider((r) => SupabaseService()))
                              .createMatch(
                                talentId: talents[i].id,
                                employerId: employer.id,
                                initiedPar: 'employeur',
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚡ Flash envoyé !'),
                              backgroundColor: Color(0xFFFFD700),
                            ),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A0A),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Talents'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Matches'),
        ],
        onTap: (i) {
          if (i == 1) context.go('/employer/talents');
        },
      ),
    );
  }
}
