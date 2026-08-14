import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../core/permissions/permission_manager.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _requestPermissions() async {
    await PermissionManager.requestStoragePermission();
    await PermissionManager.requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    title: 'Welcome to Orbitune',
                    description: 'Your premium online modern music player.',
                    icon: Icons.music_note,
                    theme: theme,
                  ),
                  _buildPage(
                    title: 'Local & Online',
                    description: 'Stream top hits from YouTube Music or play your local library seamlessly.',
                    icon: Icons.cloud_sync,
                    theme: theme,
                  ),
                  _buildPage(
                    title: 'Permissions',
                    description: 'We need storage permission to scan your local music and notification permission for background playback controls.',
                    icon: Icons.security,
                    theme: theme,
                    actionWidget: ElevatedButton(
                      onPressed: _requestPermissions,
                      child: const Text('Grant Permissions'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: List.generate(3, (index) => _buildDot(index, theme)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 2) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required ThemeData theme,
    Widget? actionWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: theme.colorScheme.primary),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (actionWidget != null) ...[
            const SizedBox(height: 30),
            actionWidget,
          ]
        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
