import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    const int currentStreak = 5;
    const int longestStreak = 7;
    const int totalDaysDetox = 18;
    const int savedHours = 45;
    const int unlockedCount = 2;
    const int totalCount = 8;
    const double progress = (unlockedCount / totalCount) * 100;

    final achievements = [
      {'id': 'first_step', 'title': 'Первый шаг', 'icon': Icons.directions_walk, 'desc': 'Завершите свой первый день детокса', 'unlocked': true, 'date': '2026-03-01'},
      {'id': '7_days', 'title': 'Неделя свободы', 'icon': Icons.whatshot, 'desc': 'Достигните 7-дневного стрика', 'unlocked': true, 'date': '2026-03-08'},
      {'id': '30_days', 'title': 'Мастер фокуса', 'icon': Icons.star, 'desc': 'Достигните 30-дневного стрика', 'unlocked': false},
      {'id': '100_hours', 'title': 'Хранитель времени', 'icon': Icons.hourglass_empty, 'desc': 'Сэкономьте 100 часов', 'unlocked': false},
      {'id': 'quiz_master', 'title': 'Ученик дзен', 'icon': Icons.psychology, 'desc': 'Пройдите 10 квизов осознанности', 'unlocked': false},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF), // from-purple-50 to-pink-50
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFFDB2777)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Достижения', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.normal)),
                  const SizedBox(height: 8),
                  const Text('Отслеживайте свой прогресс и празднуйте победы', style: TextStyle(color: Color(0xFFF3E8FF), fontSize: 14)),
                  const SizedBox(height: 24),
                  
                  // Overall Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Прогресс', style: TextStyle(color: Color(0xFFF3E8FF), fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('$unlockedCount / $totalCount', style: const TextStyle(color: Colors.white, fontSize: 24)),
                              ],
                            ),
                            const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 12,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Streak Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Текущий стрик', style: TextStyle(color: Color(0xFFFFEDD5), fontSize: 14)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$currentStreak', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.whatshot, size: 36, color: Colors.orangeAccent),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Лучший: $longestStreak дней', style: const TextStyle(color: Color(0xFFFFEDD5), fontSize: 14)),
                              ],
                            ),
                            Icon(LucideIcons.flame, color: Colors.orange.shade200, size: 60),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('До следующей награды', style: TextStyle(color: Colors.white, fontSize: 14)),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentStreak >= 14 ? 'Достигнуто!' : '${14 - currentStreak} дней',
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      if (currentStreak >= 14) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.celebration, size: 14, color: Colors.white),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (currentStreak / 14).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Стрик скопирован в буфер обмена!'))
                            );
                          },
                          icon: const Icon(LucideIcons.share2, color: Color(0xFFEA580C)),
                          label: const Text('Поделиться стриком', style: TextStyle(color: Color(0xFFEA580C))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(LucideIcons.calendar, color: Color(0xFF2563EB), size: 32),
                              const SizedBox(height: 8),
                              Text('$totalDaysDetox', style: const TextStyle(color: Colors.black, fontSize: 24)),
                              const Text('Дней детокса', style: TextStyle(color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(LucideIcons.trendingUp, color: Color(0xFF16A34A), size: 32),
                              const SizedBox(height: 8),
                              Text('${savedHours}ч', style: const TextStyle(color: Colors.black, fontSize: 24)),
                              const Text('Сэкономлено', style: TextStyle(color: Colors.black54, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Achievements List
                  const Text('Все достижения', style: TextStyle(fontSize: 20, color: AppColors.textMain)),
                  const SizedBox(height: 16),
                  ...achievements.map((ach) => _buildAchievementCard(ach)),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF9333EA)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        const Icon(Icons.auto_awesome, size: 36, color: Colors.amberAccent),
                        SizedBox(height: 12),
                        Text('Продолжайте!', style: TextStyle(color: Colors.white, fontSize: 20)),
                        SizedBox(height: 8),
                        Text(
                          'Каждое достижение - это шаг к цифровой свободе и лучшей версии себя',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Padding for nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> ach) {
    final bool unlocked = ach['unlocked'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unlocked ? Colors.grey.shade100 : Colors.grey.shade200),
          boxShadow: unlocked ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: unlocked ? const Color(0xFFFAE8FF) : const Color(0xFFE5E7EB), // from-purple-100 to-pink-100 ? approx
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: unlocked 
                    ? Icon(ach['icon'] as IconData, size: 28, color: AppColors.primary)
                    : const Icon(Icons.lock, size: 28, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ach['title'],
                        style: TextStyle(fontSize: 18, color: unlocked ? AppColors.textMain : AppColors.inactiveNav),
                      ),
                      if (!unlocked) const Icon(LucideIcons.lock, size: 16, color: AppColors.inactiveNav),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ach['desc'],
                    style: TextStyle(fontSize: 14, color: unlocked ? AppColors.textSecondary : const Color(0xFF9CA3AF)),
                  ),
                  if (unlocked && ach['date'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF), // purple-50
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Получено ${ach['date']}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9333EA)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
