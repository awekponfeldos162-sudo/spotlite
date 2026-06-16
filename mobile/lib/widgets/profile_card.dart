import 'package:flutter/material.dart';
import '../models/talent_model.dart';
import 'skill_badge.dart';

class ProfileCard extends StatefulWidget {
  final TalentModel talent;
  final VoidCallback? onLike;
  final VoidCallback? onPass;

  const ProfileCard({
    super.key,
    required this.talent,
    this.onLike,
    this.onPass,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? const Color(0xFFFFD700) : Colors.white12,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec effet projecteur
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hovered
                        ? [const Color(0xFF1A1A1A), const Color(0xFF2A2A1A)]
                        : [const Color(0xFF1A1A1A), const Color(0xFF111111)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2A2A2A),
                          border: Border.all(
                            color: _hovered
                                ? const Color(0xFFFFD700)
                                : Colors.white24,
                            width: 2,
                          ),
                          boxShadow: _hovered
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.3),
                                    blurRadius: 15,
                                  ),
                                ]
                              : [],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.talent.nom,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.talent.titre != null)
                        Text(
                          widget.talent.titre!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score de qualification
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          size: 16,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Score : ${widget.talent.scoreQualification}/100',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (widget.talent.secteur != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.talent.secteur!,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Biographie
                    if (widget.talent.biographie != null)
                      Text(
                        widget.talent.biographie!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Skills
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.talent.skills
                          .take(4)
                          .map((s) => SkillBadge(skill: s, compact: true))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onPass,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                            ),
                            label: const Text(
                              'Passer',
                              style: TextStyle(color: Colors.white54),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onLike,
                            icon: const Icon(
                              Icons.flash_on,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Flasher',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
