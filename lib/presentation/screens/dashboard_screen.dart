import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Dummy data (simulating AppContext)
  final int _dailyLimit = 180; // 3 hours
  final int _todayUsage = 145; // 2h 25m
  bool _moodSet = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.subscription,
      builder: (context, subscription, child) {
        final bool _isPremium = AppState.isPremium;
        final remainingTime = _dailyLimit - _todayUsage;
        final usagePercent = (_todayUsage / _dailyLimit).clamp(0.0, 1.0);
        final isOverLimit = _todayUsage > _dailyLimit;

        return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(remainingTime, usagePercent, isOverLimit),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Mood Check
                  if (!_moodSet) ...[
                    DashboardMoodCheckCard(onMoodSelect: (id) {
                      setState(() => _moodSet = true);
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Over Limit Alert
                  if (isOverLimit) ...[
                    _buildOverLimitAlert(),
                    const SizedBox(height: 24),
                  ],

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: const QuickStatCard(
                            icon: LucideIcons.flame,
                            value: '12',
                            label: 'дней стрик',
                            bgColor: Color(0xFFFFF7ED),
                            iconColor: Color(0xFFEA580C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: const QuickStatCard(
                            icon: LucideIcons.clock,
                            value: '45ч',
                            label: 'сэкономлено',
                            bgColor: Color(0xFFEFF6FF),
                            iconColor: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: const QuickStatCard(
                            icon: LucideIcons.award,
                            value: '18',
                            label: 'дней детокса',
                            bgColor: Color(0xFFF5F3FF),
                            iconColor: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // App Usage Section
                  ValueListenableBuilder<AppLimitData>(
                    valueListenable: AppState.appLimits,
                    builder: (context, limits, _) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Использование приложений',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _isPremium
                                    ? () => context.push('/focus-mode')
                                    : () => context.push('/premium'),
                                icon: Icon(
                                  _isPremium ? LucideIcons.zap : LucideIcons.lock,
                                  size: 14,
                                ),
                                label: Text(_isPremium ? 'Фокус' : 'Подробнее'),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppUsageCard(name: 'Instagram', icon: Icons.camera_alt, usedMinutes: 85, limitMinutes: limits.instagramLimit),
                          const SizedBox(height: 12),
                          AppUsageCard(name: 'TikTok', icon: Icons.music_note, usedMinutes: 120, limitMinutes: limits.tiktokLimit),
                          const SizedBox(height: 12),
                          AppUsageCard(name: 'YouTube', icon: Icons.play_arrow, usedMinutes: 45, limitMinutes: limits.youtubeLimit),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // AI Insights
                  _buildAiInsights(),
                  const SizedBox(height: 32),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      }
    );
  }

  Widget _buildHeader(int remainingTime, double usagePercent, bool isOverLimit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Доброе утро, ${AppState.userName.value.isNotEmpty ? AppState.userName.value : 'Нурислам'}!',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'вторник, 17 марта',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => context.push('/premium'),
                icon: const Icon(LucideIcons.crown, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Column(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 52),
              SizedBox(height: 8),
              Text(
                '12',
                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
              ),
              Text(
                'дней без срывов',
                style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Использовано сегодня', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          '${(_todayUsage / 60).floor()}ч ${_todayUsage % 60}м',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isOverLimit ? 'Превышено' : 'Осталось',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '${(remainingTime.abs() / 60).floor()}ч ${remainingTime.abs() % 60}м',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isOverLimit ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: usagePercent,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    color: isOverLimit ? Colors.redAccent : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverLimitAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertCircle, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Лимит превышен', style: TextStyle(color: Color(0xFF7F1D1D), fontWeight: FontWeight.w600)),
                const Text(
                  'Хотите заработать дополнительное время?',
                  style: TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Пройти квиз'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsights() {
    final bool premium = AppState.isPremium;
    if (premium) {
      // Show real AI insights content for premium users
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF059669).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(LucideIcons.brain, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Инсайты', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Персональный анализ за неделю', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _aiTip(Icons.trending_down, 'Вы сократили экранное время на 18% по сравнению с прошлой неделей'),
            const SizedBox(height: 8),
            _aiTip(Icons.nights_stay, 'Наибольшее время в соцсетях — вечером 19:00–22:00. Попробуйте читать книгу в это время'),
            const SizedBox(height: 8),
            _aiTip(Icons.star, 'TikTok — самый большой триггер. Рекомендуем снизить лимит до 30 мин/день'),
          ],
        ),
      );
    }

    // Locked (free) state
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
            child: const Icon(LucideIcons.brain, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('AI Инсайты', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(LucideIcons.crown, color: Colors.amber.shade300, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Получайте персональные рекомендации на основе анализа ваших привычек',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/premium'),
                  child: const Row(
                    children: [
                      Text('Разблокировать', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiTip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: LucideIcons.award,
            title: 'Достижения',
            subtitle: '2 новых',
            color: const Color(0xFFFFFBEB),
            iconColor: const Color(0xFFD97706),
            onTap: () => context.go('/achievements'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: LucideIcons.timer,
            title: 'Лимиты',
            subtitle: 'Экранное время',
            color: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            onTap: () => context.push('/change-limit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAction(
            icon: LucideIcons.shieldOff,
            title: 'Блокировка',
            subtitle: 'Демо',
            color: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            onTap: () => context.push('/block-overlay'),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: iconColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textMain)),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
