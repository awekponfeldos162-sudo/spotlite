import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioEditorScreen extends ConsumerStatefulWidget {
  const PortfolioEditorScreen({super.key});
  @override
  ConsumerState<PortfolioEditorScreen> createState() =>
      _PortfolioEditorScreenState();
}

class _PortfolioEditorScreenState extends ConsumerState<PortfolioEditorScreen> {
  final _nom = TextEditingController();
  final _titre = TextEditingController();
  final _bio = TextEditingController();
  final _skill = TextEditingController();
  String _secteur = 'Tech';
  String _statut = 'disponible';
  bool _saving = false;

  final _secteurs = ['Tech', 'Créatif', 'Finance', 'Marketing', 'RH', 'Autre'];
  final _statuts = ['disponible', 'ouvert', 'passif', 'indisponible'];

  Future<void> _save(String? talentId) async {
    setState(() => _saving = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      if (talentId != null) {
        await service.updateTalent(talentId, {
          'nom': _nom.text.trim(),
          'titre': _titre.text.trim(),
          'biographie': _bio.text.trim(),
          'secteur': _secteur,
          'statut_recherche': _statut,
        });
      }
      if (mounted) context.go('/profile');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final talentAsync = ref.watch(talentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('MODIFIER MON PROFIL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: talentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1877F2)),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (talent) {
          if (talent != null && _nom.text.isEmpty) {
            _nom.text = talent.nom;
            _titre.text = talent.titre ?? '';
            _bio.text = talent.biographie ?? '';
            _secteur = talent.secteur ?? 'Tech';
            _statut = talent.statutRecherche;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Photo de profil ──
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1877F2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Infos de base ──
              _Section(
                title: 'Informations de base',
                children: [
                  _EditField(
                    label: 'Nom complet',
                    controller: _nom,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _EditField(
                    label: 'Titre professionnel',
                    controller: _titre,
                    icon: Icons.work_outline_rounded,
                    hint: 'Ex: Flutter Developer Senior',
                  ),
                  const SizedBox(height: 12),
                  _EditField(
                    label: 'Biographie',
                    controller: _bio,
                    icon: Icons.edit_note_rounded,
                    maxLines: 3,
                    hint: 'Décrivez vos compétences et expériences...',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Secteur ──
              _Section(
                title: 'Secteur d\'activité',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _secteurs.map((s) {
                      final sel = s == _secteur;
                      return GestureDetector(
                        onTap: () => setState(() => _secteur = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF1877F2) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF1877F2)
                                  : const Color(0xFFE4E6EB),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : const Color(0xFF65676B),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Statut ──
              _Section(
                title: 'Statut de recherche',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuts.map((s) {
                      final sel = s == _statut;
                      Color color = switch (s) {
                        'disponible' => const Color(0xFF31A24C),
                        'ouvert' => const Color(0xFF1877F2),
                        'passif' => const Color(0xFFF7B928),
                        _ => const Color(0xFF65676B),
                      };
                      return GestureDetector(
                        onTap: () => setState(() => _statut = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? color : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? color : const Color(0xFFE4E6EB),
                            ),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : const Color(0xFF65676B),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Ajouter une compétence ──
              _Section(
                title: 'Ajouter une compétence',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _EditField(
                          label: 'Compétence',
                          controller: _skill,
                          icon: Icons.code_rounded,
                          hint: 'Ex: Flutter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_skill.text.trim().isEmpty || talent == null)
                            return;
                          await ref.read(supabaseServiceProvider).addSkill({
                            'talent_id': talent.id,
                            'nom': _skill.text.trim(),
                            'niveau': 'intermédiaire',
                          });
                          _skill.clear();
                          ref.invalidate(talentProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  if (talent != null && talent.skills.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: talent.skills
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F3FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.nom,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1877F2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      await ref
                                          .read(supabaseServiceProvider)
                                          .deleteSkill(s.id);
                                      ref.invalidate(talentProvider);
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: Color(0xFF1877F2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // ── Sauvegarder ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _save(talent?.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sauvegarder les modifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF050505),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final int maxLines;
  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: Color(0xFF050505)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1877F2), size: 20),
        filled: true,
        fillColor: const Color(0xFFF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF65676B), fontSize: 13),
      ),
    );
  }
}
