import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

const List<OnboardingSlide> slides = [
  OnboardingSlide(
    icon: LucideIcons.shield,
    title: 'Защитите своё время',
    description: 'DophamineGuard помогает постепенно сократить использование соцсетей без стресса и срывов',
    gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // purple-500 to pink-500
  ),
  OnboardingSlide(
    icon: LucideIcons.target,
    title: 'Персональный план',
    description: 'Выберите комфортный темп детоксикации и следуйте ежедневному плану с AI-поддержкой',
    gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // blue-500 to cyan-500
  ),
  OnboardingSlide(
    icon: LucideIcons.trendingDown,
    title: 'Плавное сокращение',
    description: 'Снижайте потребление на 70% без радикальных методов. Возвращайте 2-3 часа ежедневно',
    gradientColors: [Color(0xFF22C55E), Color(0xFF10B981)], // green-500 to emerald-500
  ),
  OnboardingSlide(
    icon: LucideIcons.sparkles,
    title: 'Геймификация',
    description: 'Зарабатывайте достижения, поддерживайте стрики и отслеживайте прогресс в реальном времени',
    gradientColors: [Color(0xFFF97316), Color(0xFFEF4444)], // orange-500 to red-500
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;

  void _handleNext() {
    if (_currentSlide < slides.length - 1) {
      setState(() {
        _currentSlide++;
      });
    } else {
      context.go('/auth'); // TODO: Create auth screen and path
    }
  }

  void _handleSkip() {
    context.go('/auth'); // TODO: Create auth screen and path
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[_currentSlide];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448), // max-w-md equivalent
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Пропустить', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),

                // Slide Content with Animation
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(_currentSlide),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          // Icon Container
                          Container(
                            width: 128,
                            height: 128,
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: slide.gradientColors,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Title
                          Text(
                            slide.title,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontSize: 28, // Matches text-3xl
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            slide.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
                ),

                // Bottom Section: Dots + Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Progress Dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            slides.length,
                            (index) {
                              final isActive = index == _currentSlide;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isActive ? 32.0 : 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Next Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9333EA), Color(0xFFDB2777)], // purple-600 to pink-600
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _handleNext,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentSlide == slides.length - 1 ? 'Начать' : 'Далее',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
