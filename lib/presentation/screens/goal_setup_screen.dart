import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/app_button.dart';

class Program {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final String reduction;
  final String duration;
  final String description;
  final List<String> features;
  final bool isFree;

  const Program({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.reduction,
    required this.duration,
    required this.description,
    required this.features,
    this.isFree = true,
  });
}

const List<Program> programs = [
  Program(
    id: 'easy',
    name: 'Легкий',
    icon: LucideIcons.target,
    gradientColors: [Color(0xFF22C55E), Color(0xFF10B981)],
    reduction: '40%',
    duration: '8 недель',
    description: 'Плавное сокращение на 5% в неделю',
    features: ['Комфортный темп', 'Минимум стресса', 'Долгосрочный результат'],
    isFree: true,
  ),
  Program(
    id: 'medium',
    name: 'Средний',
    icon: LucideIcons.zap,
    gradientColors: [Color(0xFFF97316), Color(0xFFFBBF24)],
    reduction: '60%',
    duration: '6 недель',
    description: 'Сбалансированный подход',
    features: ['Оптимальный баланс', 'Видимый прогресс', 'AI-рекомендации'],
    isFree: false,
  ),
  Program(
    id: 'intensive',
    name: 'Интенсивный',
    icon: LucideIcons.flame,
    gradientColors: [Color(0xFFEF4444), Color(0xFFEB4899)],
    reduction: '80%',
    duration: '4 недели',
    description: 'Быстрые результаты для мотивированных',
    features: ['Максимальный эффект', 'Быстрые результаты', 'Личный коучинг'],
    isFree: false,
  ),
];

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  int _step = 1;
  String _selectedProgramId = 'easy';
  double _currentUsageMinutes = 300; // 5 hours

  void _handleContinue() {
    if (_step == 1) {
      setState(() => _step = 2);
    } else {
      if (_selectedProgramId == 'easy') {
        context.go('/mood-check'); // TODO: Create mood-check route
      } else {
        context.go('/premium'); // TODO: Create premium route
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildStepBar(1),
                          const SizedBox(width: 8),
                          _buildStepBar(2),
                        ],
                      ),
                      Text(
                        'Шаг $_step из 2',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(_step),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _step == 1 ? 'Текущее использование' : 'Выберите программу',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _step == 1
                              ? 'Сколько времени вы проводите в соцсетях ежедневно?'
                              : 'Выберите комфортный темп детоксикации',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 1 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AppButton(
                text: 'Продолжить',
                onPressed: _handleContinue,
                icon: LucideIcons.arrowRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBar(int step) {
    return Container(
      height: 4,
      width: 64,
      decoration: BoxDecoration(
        color: _step >= step ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStep1() {
    final h = (_currentUsageMinutes / 60).floor();
    final m = (_currentUsageMinutes % 60).round();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Time Display Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.clock, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  '${h}ч ${m}м',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'в день',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surface,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 8,
            ),
            child: Slider(
              value: _currentUsageMinutes,
              min: 30,
              max: 480,
              divisions: 30, // 15 min steps (450/15 = 30)
              onChanged: (v) => setState(() => _currentUsageMinutes = v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('30 мин', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text('8 часов', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Info Cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: '${(h * 365).round()}ч',
                  subtitle: 'потеряно в год',
                  color: Colors.red.shade50,
                  textColor: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: '${(h * 0.7 * 365 / 365 * 60 / 60).round()}ч', // simplified
                  subtitle: 'можно вернуть',
                  color: Colors.green.shade50,
                  textColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return ListView.separated(
      itemCount: programs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prog = programs[index];
        final isSelected = _selectedProgramId == prog.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedProgramId = prog.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: prog.gradientColors),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(prog.icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  prog.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                if (!prog.isFree) ...[
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.crown, size: 14, color: Colors.amber),
                                ],
                              ],
                            ),
                            Text(
                              '${prog.duration} • ${prog.reduction}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.inactiveNav,
                          width: 2,
                        ),
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check, size: 16, color: Colors.white),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prog.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prog.features.map((f) => _FeatureBadge(text: f)).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String text;

  const _FeatureBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
