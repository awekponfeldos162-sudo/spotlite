import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/media_service.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _content = TextEditingController();
  final _mediaService = MediaService();
  final _postService = PostService();

  File? _localFile;
  String? _mediaUrl;
  String _mediaType = 'none';
  bool _uploading = false;
  bool _posting = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _uploading = true);
    final url = await _mediaService.pickAndUploadImage();
    setState(() {
      _mediaUrl = url;
      _mediaType = 'image';
      _uploading = false;
    });
  }

  Future<void> _pickVideo() async {
    setState(() => _uploading = true);
    final url = await _mediaService.pickAndUploadVideo();
    setState(() {
      _mediaUrl = url;
      _mediaType = 'video';
      _uploading = false;
    });
  }

  Future<void> _publish() async {
    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Décrivez votre projet'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      // Extraire les hashtags du contenu
      final hashtags = _content.text
          .split(' ')
          .where((w) => w.startsWith('#'))
          .toList();

      await _postService.createPost(
        profileId: uid,
        content: _content.text.trim(),
        mediaUrl: _mediaUrl,
        mediaType: _mediaType,
        hashtags: hashtags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Projet publié avec succès !'),
            backgroundColor: Color(0xFF31A24C),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/feed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NOUVEAU PROJET'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go('/feed'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: _posting ? null : _publish,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _posting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Publier',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Auteur ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1877F2),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: Supabase.instance.client
                          .from('talents')
                          .select('nom')
                          .eq(
                            'profile_id',
                            Supabase.instance.client.auth.currentUser?.id ?? '',
                          )
                          .maybeSingle(),
                      builder: (context, snap) => Text(
                        snap.data?['nom'] ?? 'Mon profil',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF050505),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F3FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            size: 12,
                            color: Color(0xFF1877F2),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Public',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Texte ──
            TextField(
              controller: _content,
              maxLines: 6,
              style: const TextStyle(fontSize: 15, color: Color(0xFF050505)),
              decoration: InputDecoration(
                hintText:
                    'Décrivez votre projet... Ajoutez des #hashtags pour vos compétences',
                hintStyle: const TextStyle(
                  color: Color(0xFF65676B),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 12),

            // ── Aperçu média ──
            if (_uploading)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1877F2)),
                      SizedBox(height: 8),
                      Text(
                        'Upload en cours...',
                        style: TextStyle(color: Color(0xFF1877F2)),
                      ),
                    ],
                  ),
                ),
              ),

            if (_mediaUrl != null && !_uploading)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _mediaUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _mediaUrl = null;
                        _mediaType = 'none';
                      }),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE4E6EB)),
            const SizedBox(height: 12),

            // ── Actions média ──
            const Text(
              'Ajouter à votre projet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF050505),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MediaBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'Image',
                  color: const Color(0xFF44BCA0),
                  onTap: _pickImage,
                ),
                const SizedBox(width: 10),
                _MediaBtn(
                  icon: Icons.videocam_rounded,
                  label: 'Vidéo démo',
                  color: const Color(0xFFFF6B35),
                  onTap: _pickVideo,
                ),
                const SizedBox(width: 10),
                _MediaBtn(
                  icon: Icons.link_rounded,
                  label: 'Lien',
                  color: const Color(0xFF1877F2),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Hashtags suggestions ──
            const Text(
              'Hashtags suggérés',
              style: TextStyle(fontSize: 12, color: Color(0xFF65676B)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  [
                        '#Flutter',
                        '#React',
                        '#Figma',
                        '#Python',
                        '#DevOps',
                        '#UX',
                        '#Mobile',
                        '#IA',
                      ]
                      .map(
                        (tag) => GestureDetector(
                          onTap: () {
                            final current = _content.text;
                            if (!current.contains(tag)) {
                              _content.text = '$current $tag ';
                              _content.selection = TextSelection.fromPosition(
                                TextPosition(offset: _content.text.length),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F3FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1877F2),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MediaBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
