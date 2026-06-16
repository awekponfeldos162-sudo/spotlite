import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _index(String loc) {
    if (loc.startsWith('/feed')) return 0;
    if (loc.startsWith('/network')) return 1;
    if (loc.startsWith('/challenges')) return 3;
    if (loc.startsWith('/notifications')) return 4;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _index(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavBtn(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: idx == 0,
                  onTap: () => context.go('/feed'),
                ),
                _NavBtn(
                  icon: Icons.people_rounded,
                  label: 'Réseau',
                  active: idx == 1,
                  onTap: () => context.go('/network'),
                ),

                // FAB central
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go('/create'),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1877F2).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),

                _NavBtn(
                  icon: Icons.emoji_events_rounded,
                  label: 'Challenges',
                  active: idx == 3,
                  onTap: () => context.go('/challenges'),
                ),
                _NavBtn(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  active: idx == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1877F2) : const Color(0xFFBCC0C4);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
