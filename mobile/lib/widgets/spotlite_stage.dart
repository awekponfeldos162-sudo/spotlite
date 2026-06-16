import 'package:flutter/material.dart';
import 'dart:convert';

// ─────────────────────────────────────────
// Modèle d'un bloc du Stage
// ─────────────────────────────────────────
class StageBloc {
  final String id;
  final String type; // 'texte', 'image', 'skill_badge', 'lien', 'video'
  Offset position;
  Size taille;
  final Map<String, dynamic> contenu;

  StageBloc({
    required this.id,
    required this.type,
    required this.position,
    required this.taille,
    required this.contenu,
  });

  factory StageBloc.fromMap(Map<String, dynamic> map) => StageBloc(
    id: map['id'],
    type: map['type'],
    position: Offset(
      (map['position']['x'] as num).toDouble(),
      (map['position']['y'] as num).toDouble(),
    ),
    taille: Size(
      (map['taille']['w'] as num).toDouble(),
      (map['taille']['h'] as num).toDouble(),
    ),
    contenu: Map<String, dynamic>.from(map['contenu']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'position': {'x': position.dx, 'y': position.dy},
    'taille': {'w': taille.width, 'h': taille.height},
    'contenu': contenu,
  };
}

// ─────────────────────────────────────────
// Composant principal : SpotliteStage
// ─────────────────────────────────────────
class SpotliteStage extends StatefulWidget {
  final List<Map<String, dynamic>> blocsJson;
  final bool editMode;
  final void Function(List<Map<String, dynamic>>)? onChanged;

  const SpotliteStage({
    super.key,
    required this.blocsJson,
    this.editMode = false,
    this.onChanged,
  });

  @override
  State<SpotliteStage> createState() => _SpotliteStageState();
}

class _SpotliteStageState extends State<SpotliteStage> {
  late List<StageBloc> _blocs;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _blocs = widget.blocsJson.map((b) => StageBloc.fromMap(b)).toList();
  }

  void _onBlocMoved(String id, Offset newPosition) {
    setState(() {
      final bloc = _blocs.firstWhere((b) => b.id == id);
      bloc.position = newPosition;
    });
    _notifyChanged();
  }

  void _notifyChanged() {
    widget.onChanged?.call(_blocs.map((b) => b.toMap()).toList());
  }

  void _addBloc(String type) {
    final newBloc = StageBloc(
      id: 'bloc_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      position: const Offset(20, 20),
      taille: const Size(200, 80),
      contenu: _defaultContenu(type),
    );
    setState(() => _blocs.add(newBloc));
    _notifyChanged();
  }

  void _deleteBloc(String id) {
    setState(() => _blocs.removeWhere((b) => b.id == id));
    _notifyChanged();
  }

  Map<String, dynamic> _defaultContenu(String type) => switch (type) {
    'texte' => {'texte': 'Nouveau texte'},
    'skill_badge' => {'skill': 'Compétence', 'verified': false},
    'lien' => {'url': 'https://', 'label': 'Mon lien'},
    'image' => {'url': '', 'description': ''},
    _ => {},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Barre d'outils (mode édition) ──
        if (widget.editMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF111111),
            child: Row(
              children: [
                const Text(
                  'Ajouter :',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 8),
                _AddButton(label: '📝 Texte', onTap: () => _addBloc('texte')),
                _AddButton(
                  label: '⭐ Skill',
                  onTap: () => _addBloc('skill_badge'),
                ),
                _AddButton(label: '🔗 Lien', onTap: () => _addBloc('lien')),
                _AddButton(label: '🖼️ Image', onTap: () => _addBloc('image')),
              ],
            ),
          ),

        // ── Zone du Stage ──
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFF0A0A0A),
            child: _blocs.isEmpty
                ? _buildEmptyState()
                : Stack(
                    children: [
                      // Grille de fond (effet scène)
                      if (widget.editMode) _buildGrid(),

                      // Blocs déplaçables
                      ..._blocs.map(
                        (bloc) => _DraggableBloc(
                          key: ValueKey(bloc.id),
                          bloc: bloc,
                          editMode: widget.editMode,
                          isSelected: _selectedId == bloc.id,
                          onTap: () => setState(() => _selectedId = bloc.id),
                          onMoved: (pos) => _onBlocMoved(bloc.id, pos),
                          onDelete: () => _deleteBloc(bloc.id),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.highlight, size: 64, color: Color(0xFFFFD700)),
          const SizedBox(height: 16),
          const Text(
            'Votre Stage est vide',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          if (widget.editMode) ...[
            const SizedBox(height: 8),
            const Text(
              'Ajoutez des blocs pour construire votre portfolio',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(size: Size.infinite, painter: _GridPainter());
  }
}

// ─────────────────────────────────────────
// Bloc déplaçable
// ─────────────────────────────────────────
class _DraggableBloc extends StatefulWidget {
  final StageBloc bloc;
  final bool editMode;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(Offset) onMoved;
  final VoidCallback onDelete;

  const _DraggableBloc({
    super.key,
    required this.bloc,
    required this.editMode,
    required this.isSelected,
    required this.onTap,
    required this.onMoved,
    required this.onDelete,
  });

  @override
  State<_DraggableBloc> createState() => _DraggableBlocState();
}

class _DraggableBlocState extends State<_DraggableBloc>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.2,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.bloc.position.dx,
      top: widget.bloc.position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: widget.editMode
            ? (details) => widget.onMoved(widget.bloc.position + details.delta)
            : null,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (context, child) => Container(
            width: widget.bloc.taille.width,
            height: widget.bloc.taille.height,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? const Color(0xFFFFD700)
                    : Colors.white12,
                width: widget.isSelected ? 1.5 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFFFFD700,
                        ).withOpacity(_glow.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Contenu du bloc
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildBlocContent(),
                ),

                // Bouton supprimer (mode édition)
                if (widget.editMode && widget.isSelected)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Icône de déplacement (mode édition)
                if (widget.editMode)
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.drag_indicator,
                      size: 14,
                      color: Colors.white24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlocContent() {
    return switch (widget.bloc.type) {
      'texte' => Text(
        widget.bloc.contenu['texte'] ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
      'skill_badge' => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.bloc.contenu['verified'] == true)
            const Icon(Icons.verified, size: 14, color: Color(0xFFFFD700)),
          const SizedBox(width: 4),
          Text(
            widget.bloc.contenu['skill'] ?? '',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      'lien' => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.bloc.contenu['label'] ?? '',
              style: const TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      'image' =>
        widget.bloc.contenu['url']?.isNotEmpty == true
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.bloc.contenu['url'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white24),
                ),
              )
            : const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white24,
                  size: 32,
                ),
              ),
      _ => const Icon(Icons.widgets_outlined, color: Colors.white24),
    };
  }
}

// ─────────────────────────────────────────
// Bouton d'ajout de bloc
// ─────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Grille de fond (effet scène / studio)
// ─────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
