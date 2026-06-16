import 'package:flutter/material.dart';
import '../models/skill_model.dart';

class SkillBadge extends StatelessWidget {
  final SkillModel skill;
  final bool compact;
  const SkillBadge({super.key, required this.skill, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: skill.isVerified
            ? const Color(0xFF1877F2)
            : const Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (skill.isVerified) ...[
            const Icon(Icons.check_rounded, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            skill.nom,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: skill.isVerified ? Colors.white : const Color(0xFF1877F2),
            ),
          ),
        ],
      ),
    );
  }
}
