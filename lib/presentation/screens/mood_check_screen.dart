import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

class Mood {
  final String id;
  final String emoji;
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final String message;

  const Mood({
    required this.id,
    required this.emoji,
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.message,
  });
}

const List<Mood> moods = [
  Mood(
    id: 'great',
    emoji: '😊',
    label: 'Отлично',
    icon: LucideIcons.sun,
    gradientColors: [Color(0xFFFBBF24), Color(0xFFFB923C)],
    message: 'Прекрасно! Отличный день для достижений!',
  ),
  Mood(
    id: 'good',
    emoji: '🙂',
    label: 'Хорошо',
    icon: LucideIcons.sunrise,
    gradientColors: [Color(0xFF4ADE80), Color(0xFF10B981)],
    message: 'Здорово! Продолжайте в том же духе!',
  ),
  Mood(
    id: 'okay',
    emoji: '😐',
    label: 'Нормально',
    icon: LucideIcons.cloud,
    gradientColors: [Color(0xFF60A5FA), Color(0xFF22D3EE)],
    message: 'Сегодня может быть сложнее, но вы справитесь!',
  ),
  Mood(
    id: 'bad',
    emoji: '😔',
    label: 'Не очень',
    icon: LucideIcons.cloudRain,
    gradientColors: [Color(0xFF94A3B8), Color(0xFF475569)],
    message: 'Помните: это временно. Мы здесь, чтобы помочь.',
  ),
];

class MoodCheckScreen extends StatefulWidget {
  const MoodCheckScreen({super.key});

  @override
  State<MoodCheckScreen> createState() => _MoodCheckScreenState();
}

class _MoodCheckScreenState extends State<MoodCheckScreen> {
  String? _selectedMoodId;
  bool _showMessage = false;

  void _handleMoodSelect(String moodId) {
    setState(() {
      _selectedMoodId = moodId;
      _showMessage = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFFDF2F8),
              Color(0xFFFFF7ED),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showMessage ? _buildMessage() : _buildSelection(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelection() {
    return Column(
      key: const ValueKey('selection'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        const Icon(LucideIcons.sun, size: 60, color: Colors.orange),
        const SizedBox(height: 16),
        const Text(
          'Доброе утро!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        const Text(
          'Как ваше настроение сегодня?',
          style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 48),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: moods.length,
          itemBuilder: (context, index) {
            final mood = moods[index];
            return GestureDetector(
              onTap: () => _handleMoodSelect(mood.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mood.icon, size: 48, color: mood.gradientColors.first),
                    const SizedBox(height: 12),
                    Text(
                      mood.label,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: mood.gradientColors),
                        shape: BoxShape.circle,
                        // opacity is handled by colors here
                      ),
                      child: Icon(mood.icon, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),
        TextButton(
          onPressed: () => context.go('/dashboard'),
          child: const Text(
            'Пропустить',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    final mood = moods.firstWhere((m) => m.id == _selectedMoodId);
    return Column(
      key: const ValueKey('message'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(mood.icon, size: 72, color: mood.gradientColors.first),
              const SizedBox(height: 16),
              Text(
                mood.label,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                mood.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BounceDot(delay: 0),
                  SFixedSizeBox(width: 8),
                  _BounceDot(delay: 150),
                  SFixedSizeBox(width: 8),
                  _BounceDot(delay: 300),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SFixedSizeBox extends StatelessWidget {
  final double width;
  const SFixedSizeBox({this.width = 0, super.key});
  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

class _BounceDot extends StatefulWidget {
  final int delay;
  const _BounceDot({required this.delay});

  @override
  State<_BounceDot> createState() => _BounceDotState();
}

class _BounceDotState extends State<_BounceDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
