import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/skill_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talentAsync = ref.watch(talentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('MON PROFIL'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: talentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1877F2)),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (talent) {
          if (talent == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    size: 64,
                    color: Color(0xFF1877F2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Complétez votre profil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/editor'),
                    child: const Text('Créer mon profil'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              // ── Cover + Avatar ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(height: 120, color: const Color(0xFF1877F2)),
                  Positioned(
                    bottom: 6,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Color(0xFF050505),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Modifier',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF050505),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.only(top: -36),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1877F2),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/editor'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F3FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFF1877F2),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Modifier profil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1877F2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      talent.nom,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF050505),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          talent.titre ?? 'Talent Spotlite',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF65676B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            talent.statutRecherche,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E7E34),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _StatItem('${talent.scoreQualification}', 'Score'),
                          _StatItem('1.2k', 'Vues'),
                          _StatItem('14', 'Matches'),
                          _StatItem('3', 'Challenges'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Compétences ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFF1877F2),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Compétences validées',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050505),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    talent.skills.isEmpty
                        ? const Text(
                            'Aucune compétence ajoutée',
                            style: TextStyle(color: Color(0xFF65676B)),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: talent.skills
                                .map((s) => SkillBadge(skill: s))
                                .toList(),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── À propos ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF1877F2),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'À propos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050505),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (talent.localisation != null)
                      _AboutRow(
                        Icons.location_on_rounded,
                        talent.localisation!,
                      ),
                    if (talent.secteur != null)
                      _AboutRow(Icons.work_rounded, talent.secteur!),
                    if (talent.biographie != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          talent.biographie!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF050505),
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFFE4E6EB), width: 0.5),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF65676B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AboutRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF65676B)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF050505)),
          ),
        ],
      ),
    );
  }
}
