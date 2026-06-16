import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main_shell.dart';
import 'screens/talent/feed_screen.dart';
import 'screens/talent/profile_screen.dart';
import 'screens/talent/challenges_screen.dart';
import 'screens/talent/notifications_screen.dart';
import 'screens/talent/network_screen.dart';
import 'screens/talent/create_post_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = session != null;
    final loc = state.matchedLocation;
    final pub = ['/login', '/signup'];
    if (!isAuth && !pub.contains(loc)) return '/login';
    if (isAuth && pub.contains(loc)) return '/feed';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
    GoRoute(path: '/create', builder: (c, s) => const CreatePostScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/feed', builder: (c, s) => const FeedScreen()),
        GoRoute(path: '/network', builder: (c, s) => const NetworkScreen()),
        GoRoute(
          path: '/challenges',
          builder: (c, s) => const ChallengesScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (c, s) => const NotificationsScreen(),
        ),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      ],
    ),
  ],
);
