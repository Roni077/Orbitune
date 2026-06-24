import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRequestingPermission = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestPermissions() async {
    if (_isRequestingPermission) return;
    setState(() => _isRequestingPermission = true);

    final permsService = ref.read(permissionsServiceProvider);
    final granted = await permsService.requestMediaPermissions();

    if (!mounted) return;

    setState(() => _isRequestingPermission = false);

    if (granted) {
      // Also optionally run a quick scan in the background
      ref.read(mediaScannerServiceProvider).scanAndSaveAudios();
      _nextPage();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to find your local music files.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    // The router should automatically redirect, but we can explicitly push if needed
    // However, since we'll wire up redirect based on `onboardingCompletedProvider`,
    // it will automatically trigger a router refresh.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable manual swipe to force user through buttons
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              // Slide 1: Welcome
              _buildSlide(
                title: 'Welcome to Orbitune',
                description: 'A beautiful, fast, and feature-rich local music player designed for audiophiles.',
                icon: Icons.music_note_rounded,
                buttonText: 'Next',
                onButtonPressed: _nextPage,
              ),

              // Slide 2: Permissions
              _buildSlide(
                title: 'We Need Access',
                description: 'Orbitune needs access to your local storage to find and play your music files. Your data never leaves your device.',
                icon: Icons.folder_special_rounded,
                buttonText: 'Grant Permission',
                onButtonPressed: _requestPermissions,
                isLoading: _isRequestingPermission,
              ),

              // Slide 3: Ready
              _buildSlide(
                title: "You're All Set!",
                description: "We're scanning your library in the background. Get ready to experience your music like never before.",
                icon: Icons.check_circle_outline_rounded,
                buttonText: "Let's Go",
                onButtonPressed: _completeOnboarding,
              ),
            ],
          ),

          // Progress dots
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: theme.colorScheme.primary,
          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms).fadeIn(),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms).fadeIn(),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}
