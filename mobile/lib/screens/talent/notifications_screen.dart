import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: const [
          _NotifHeader('Nouvelles · 3'),
          _NotifItem(
            icon: Icons.business_rounded,
            name: 'TechCorp Africa',
            message: ' a flashé votre profil et souhaite vous contacter !',
            time: 'Il y a 2 minutes',
            type: NotifType.match,
            unread: true,
          ),
          _NotifItem(
            icon: Icons.person_rounded,
            name: 'Jason M.',
            message: ' a validé votre compétence React. +5 pts au score !',
            time: 'Il y a 15 min',
            type: NotifType.validation,
            unread: true,
          ),
          _NotifItem(
            icon: Icons.business_rounded,
            name: 'Google EMEA',
            message: ' a consulté votre profil 3 fois cette semaine.',
            time: 'Il y a 1h',
            type: NotifType.view,
            unread: true,
          ),
          _NotifHeader('Plus tôt'),
          _NotifItem(
            icon: Icons.person_rounded,
            name: 'Kim L.',
            message: ' et 12 autres ont aimé votre publication PWA.',
            time: 'Hier',
            type: NotifType.like,
            unread: false,
          ),
          _NotifItem(
            icon: Icons.business_rounded,
            name: 'Studio Créatif',
            message: ' a accepté votre réponse au challenge Design System !',
            time: 'Hier',
            type: NotifType.match,
            unread: false,
          ),
          _NotifItem(
            icon: Icons.person_rounded,
            name: 'Marc D.',
            message: ' a validé votre compétence Figma.',
            time: 'Il y a 2 jours',
            type: NotifType.validation,
            unread: false,
          ),
        ],
      ),
    );
  }
}

enum NotifType { match, validation, view, like }

class _NotifHeader extends StatelessWidget {
  final String title;
  const _NotifHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF65676B),
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final String name, message, time;
  final NotifType type;
  final bool unread;
  const _NotifItem({
    required this.icon,
    required this.name,
    required this.message,
    required this.time,
    required this.type,
    required this.unread,
  });

  Color get _badgeColor => switch (type) {
    NotifType.match => const Color(0xFF1877F2),
    NotifType.validation => const Color(0xFF31A24C),
    NotifType.view => const Color(0xFF9B59B6),
    NotifType.like => const Color(0xFFFF6B35),
  };

  IconData get _badgeIcon => switch (type) {
    NotifType.match => Icons.bolt_rounded,
    NotifType.validation => Icons.check_rounded,
    NotifType.view => Icons.remove_red_eye_rounded,
    NotifType.like => Icons.thumb_up_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: unread ? const Color(0xFFF0F7FF) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1877F2),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(_badgeIcon, color: Colors.white, size: 8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF050505),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: message),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF1877F2),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
