import 'package:flutter/material.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int _filter = 0;
  final filters = ['Tous', 'Premium', 'Tech', 'Design', 'Marketing'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('CHALLENGES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.white,
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: filters.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _filter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _filter == i
                        ? const Color(0xFF1877F2)
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      filters[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _filter == i
                            ? Colors.white
                            : const Color(0xFF65676B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: const [
                _ChallengeCard(
                  company: 'TechCorp Africa',
                  location: 'Startup · Abidjan',
                  title: 'Construire une PWA offline-first',
                  description:
                      'Créer une application web progressive fonctionnant sans connexion avec synchronisation automatique.',
                  tags: ['#React', '#ServiceWorker', '#IndexedDB'],
                  days: '7 jours restants',
                  points: '+25 pts',
                  isPremium: true,
                ),
                SizedBox(height: 6),
                _ChallengeCard(
                  company: 'Studio Créatif',
                  location: 'Agence · Paris',
                  title: 'Designer un système de paiement',
                  description:
                      'Concevoir les flows UX d\'un checkout en 3 étapes pour mobile avec tests utilisateurs.',
                  tags: ['#Figma', '#UX', '#Prototype'],
                  days: '3 jours restants',
                  points: '+15 pts',
                  isPremium: false,
                ),
                SizedBox(height: 6),
                _ChallengeCard(
                  company: 'Google EMEA',
                  location: 'Big Tech · Remote',
                  title: 'Optimiser un ML Pipeline',
                  description:
                      'Réduire la latence d\'inférence d\'un modèle de classification de 40% minimum.',
                  tags: ['#Python', '#TensorFlow', '#MLOps'],
                  days: '14 jours',
                  points: '+40 pts',
                  isPremium: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String company, location, title, description, days, points;
  final List<String> tags;
  final bool isPremium;
  const _ChallengeCard({
    required this.company,
    required this.location,
    required this.title,
    required this.description,
    required this.tags,
    required this.days,
    required this.points,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPremium)
            Container(
              color: const Color(0xFF1877F2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: const Row(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFF7B928), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'PREMIUM CHALLENGE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isPremium
                            ? const Color(0xFF1877F2)
                            : const Color(0xFFE7F3FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        color: isPremium
                            ? Colors.white
                            : const Color(0xFF1877F2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF050505),
                          ),
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF65676B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF050505),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF65676B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FF),
              border: Border(
                top: BorderSide(color: Color(0xFFE4E6EB), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: Color(0xFF65676B),
                ),
                const SizedBox(width: 4),
                Text(
                  days,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF65676B),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Color(0xFFF7B928),
                ),
                const SizedBox(width: 3),
                Text(
                  points,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF050505),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Postuler',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
