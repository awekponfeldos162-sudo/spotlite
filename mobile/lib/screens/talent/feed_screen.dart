import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/post_service.dart';
import '../../providers/auth_provider.dart';
import 'create_post_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});
  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _postService = PostService();
  final _authors = <String, Map<String, dynamic>>{};

  Future<Map<String, dynamic>> _getAuthor(String profileId) async {
    if (_authors.containsKey(profileId)) return _authors[profileId]!;
    final author = await _postService.getPostAuthor(profileId);
    _authors[profileId] = author;
    return author;
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('SPOTLITE'),
        actions: [
          _IconBtn(Icons.search_rounded),
          _IconBtn(Icons.notifications_outlined),
          _IconBtn(Icons.message_outlined),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postService.feedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1877F2)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];

          return RefreshIndicator(
            color: const Color(0xFF1877F2),
            onRefresh: () async => setState(() => _authors.clear()),
            child: ListView.builder(
              itemCount: posts.length + 2, // +2 pour stories + composer
              itemBuilder: (context, index) {
                if (index == 0) return _StoriesBar();
                if (index == 1) return _Composer(uid: uid);

                final post = posts[index - 2];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getAuthor(post['profile_id']),
                  builder: (context, authorSnap) {
                    if (!authorSnap.hasData) {
                      return const _PostSkeleton();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 6),
                        _PostCard(
                          post: post,
                          author: authorSnap.data!,
                          uid: uid,
                          postService: _postService,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── AppBar Icon ──────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn(this.icon);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

// ── Stories ──────────────────────────────
class _StoriesBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('talents')
          .select('nom, profile_id, profiles(avatar_url)')
          .limit(6),
      builder: (context, snap) {
        final talents = snap.data ?? [];
        return Container(
          color: Colors.white,
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: talents.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _StoryItem(name: 'Ajouter', isAdd: true);
              }
              final t = talents[i - 1];
              return _StoryItem(
                name: t['nom'] ?? '',
                avatarUrl: t['profiles']?['avatar_url'],
                isNew: true,
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isAdd;
  final bool isNew;
  const _StoryItem({
    required this.name,
    this.avatarUrl,
    this.isAdd = false,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAdd ? const Color(0xFFE7F3FF) : const Color(0xFF1877F2),
              border: Border.all(
                color: isAdd
                    ? const Color(0xFF1877F2)
                    : isNew
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF1877F2),
                width: 2,
              ),
            ),
            child: avatarUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    isAdd ? Icons.add_rounded : Icons.person_rounded,
                    color: isAdd ? const Color(0xFF1877F2) : Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 48,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Color(0xFF65676B)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Composer ─────────────────────────────
class _Composer extends StatelessWidget {
  final String uid;
  const _Composer({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(size: 36),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _QuickPostSheet()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Partagez un projet...',
                      style: TextStyle(color: Color(0xFF65676B), fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 14, color: Color(0xFFE4E6EB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ComposeAction(
                Icons.photo_library_rounded,
                'Photo/Vidéo',
                const Color(0xFF44BCA0),
              ),
              _ComposeAction(
                Icons.tag_rounded,
                '#Skill',
                const Color(0xFF1877F2),
              ),
              _ComposeAction(
                Icons.mood_rounded,
                'Humeur',
                const Color(0xFFF7B928),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComposeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ComposeAction(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}

// ── Post Card ────────────────────────────
class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> author;
  final String uid;
  final PostService postService;
  const _PostCard({
    required this.post,
    required this.author,
    required this.uid,
    required this.postService,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late int _likes;
  bool _liked = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.post['likes_count'] ?? 0;
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    if (widget.uid.isEmpty) return;
    final liked = await widget.postService.hasLiked(
      widget.post['id'],
      widget.uid,
    );
    if (mounted) setState(() => _liked = liked);
  }

  Future<void> _toggleLike() async {
    if (widget.uid.isEmpty || _loading) return;
    setState(() => _loading = true);
    final nowLiked = await widget.postService.toggleLike(
      widget.post['id'],
      widget.uid,
    );
    setState(() {
      _liked = nowLiked;
      _likes += nowLiked ? 1 : -1;
      _loading = false;
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommentsSheet(
        postId: widget.post['id'],
        uid: widget.uid,
        postService: widget.postService,
      ),
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    return timeago.format(DateTime.parse(dateStr), locale: 'fr');
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.author;
    final post = widget.post;
    final mediaUrl = post['media_url'] as String?;
    final content = post['content'] as String? ?? '';
    final createdAt = post['created_at'] as String?;
    final isEmployer = author['type'] == 'employeur';

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                _Avatar(
                  size: 42,
                  url: author['avatar'],
                  isEmployer: isEmployer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author['nom'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF050505),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            author['titre'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF65676B),
                            ),
                          ),
                          if (author['score'] != null &&
                              author['score'] > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F7FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 10,
                                    color: Color(0xFFF7B928),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${author['score']}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1877F2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _timeAgo(createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF65676B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded, color: Color(0xFF65676B)),
              ],
            ),
          ),

          // ── Texte ──
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text.rich(
                TextSpan(
                  children: content.split(' ').map((word) {
                    if (word.startsWith('#')) {
                      return TextSpan(
                        text: '$word ',
                        style: const TextStyle(
                          color: Color(0xFF1877F2),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    }
                    return TextSpan(
                      text: '$word ',
                      style: const TextStyle(
                        color: Color(0xFF050505),
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // ── Média ──
          if (mediaUrl != null && mediaUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: mediaUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 220,
                color: const Color(0xFFE7F3FF),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1877F2)),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 220,
                color: const Color(0xFFE7F3FF),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: Color(0xFF1877F2),
                    size: 48,
                  ),
                ),
              ),
            ),

          // ── Stats ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1877F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up_rounded,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likes réactions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF65676B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE4E6EB),
            indent: 12,
            endIndent: 12,
          ),

          // ── Actions ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                _ActionBtn(
                  icon: _liked
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_alt_outlined,
                  label: "J'aime",
                  color: _liked
                      ? const Color(0xFF1877F2)
                      : const Color(0xFF65676B),
                  onTap: _toggleLike,
                ),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Commenter',
                  color: const Color(0xFF65676B),
                  onTap: _showComments,
                ),
                _ActionBtn(
                  icon: Icons.bolt_rounded,
                  label: 'Flasher',
                  color: isEmployer
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFBCC0C4),
                  onTap: isEmployer
                      ? () async {
                          await widget.postService.flashTalent(
                            talentProfileId: post['profile_id'],
                            employerProfileId: widget.uid,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚡ Flash envoyé !'),
                                backgroundColor: Color(0xFFFF6B35),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

// ── Avatar ───────────────────────────────
class _Avatar extends StatelessWidget {
  final double size;
  final String? url;
  final bool isEmployer;
  const _Avatar({required this.size, this.url, this.isEmployer = false});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF1877F2),
    ),
    child: url != null
        ? ClipOval(
            child: CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover),
          )
        : Icon(
            isEmployer ? Icons.business_rounded : Icons.person_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
  );
}

// ── Skeleton loading ─────────────────────
class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Bone(width: 42, height: 42, circle: true),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 120, height: 12),
                const SizedBox(height: 6),
                _Bone(width: 80, height: 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        _Bone(width: double.infinity, height: 12),
        const SizedBox(height: 6),
        _Bone(width: 200, height: 12),
        const SizedBox(height: 10),
        _Bone(width: double.infinity, height: 180),
      ],
    ),
  );
}

class _Bone extends StatelessWidget {
  final double width, height;
  final bool circle;
  const _Bone({required this.width, required this.height, this.circle = false});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE4E6EB),
      borderRadius: circle
          ? BorderRadius.circular(height / 2)
          : BorderRadius.circular(6),
    ),
  );
}

// ── Comments Sheet ───────────────────────
class _CommentsSheet extends StatefulWidget {
  final String postId, uid;
  final PostService postService;
  const _CommentsSheet({
    required this.postId,
    required this.uid,
    required this.postService,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Commentaires',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF050505),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4E6EB)),

          // Liste commentaires
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.postService.commentsStream(widget.postId),
              builder: (context, snap) {
                final comments = snap.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun commentaire. Soyez le premier !',
                      style: TextStyle(color: Color(0xFF65676B)),
                    ),
                  );
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Avatar(size: 32),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                c['content'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF050505),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input commentaire
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE4E6EB), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                _Avatar(size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Écrire un commentaire...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF65676B),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    if (_ctrl.text.trim().isEmpty) return;
                    await widget.postService.addComment(
                      widget.postId,
                      widget.uid,
                      _ctrl.text.trim(),
                    );
                    _ctrl.clear();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1877F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
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

// ── Quick Post Sheet ─────────────────────
class _QuickPostSheet extends StatelessWidget {
  const _QuickPostSheet();

  @override
  Widget build(BuildContext context) {
    return const CreatePostScreen();
  }
}

// Import pour éviter l'erreur circulaire
