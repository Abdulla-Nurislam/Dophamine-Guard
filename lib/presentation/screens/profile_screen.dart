import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';
import '../../data/models/usage_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/usage_repository.dart';
import '../../data/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UsageRepository _usageRepo = UsageRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isWeekView = true;
  int _selectedDayIndex = DateTime.now().weekday - 1;

  static const _daysShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _daysFull = [
    'Понедельник', 'Вторник', 'Среда',
    'Четверг', 'Пятница', 'Суббота', 'Воскресенье',
  ];

  @override
  void initState() {
    super.initState();
    _usageRepo.seedUsageDataIfEmpty();
  }

  // ── Генератор почасовых данных (уникальных для каждого дня) ──
  List<double> _generateHourlyData(int dayIndex) {
    final rng = Random(dayIndex * 31 + 7);
    return List.generate(24, (hour) {
      // Ночь (0-6): минимум использования
      if (hour < 6) return rng.nextDouble() * 5;
      // Утро (6-9): средний уровень
      if (hour < 9) return 5 + rng.nextDouble() * 20;
      // Рабочий день (9-17): может быть и 0, и всплеск
      if (hour < 17) return 10 + rng.nextDouble() * 35;
      // Вечер (17-22): пик использования
      if (hour < 22) return 20 + rng.nextDouble() * 50;
      // Поздний вечер (22-24): спад
      return 5 + rng.nextDouble() * 15;
    });
  }

  // ── Разбивка категорий за конкретный день ──
  List<Map<String, dynamic>> _generateDayCategories(int dayIndex) {
    final rng = Random(dayIndex * 17 + 3);
    final allApps = [
      {'name': 'Instagram', 'icon': LucideIcons.instagram},
      {'name': 'TikTok', 'icon': Icons.music_note},
      {'name': 'YouTube', 'icon': LucideIcons.youtube},
      {'name': 'Safari', 'icon': LucideIcons.globe},
      {'name': 'Telegram', 'icon': LucideIcons.messageCircle},
    ];
    // Перемешиваем и берём 3-4 приложения
    allApps.shuffle(rng);
    final count = 3 + rng.nextInt(2);
    return allApps.take(count).map((app) {
      final mins = 15 + rng.nextInt(180);
      return {
        'name': app['name'] as String,
        'icon': app['icon'] as IconData,
        'minutes': mins,
      };
    }).toList()
      ..sort((a, b) => (b['minutes'] as int).compareTo(a['minutes'] as int));
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'instagram': return LucideIcons.instagram;
      case 'tiktok': return Icons.music_note;
      case 'youtube': return LucideIcons.youtube;
      case 'safari': return LucideIcons.globe;
      case 'telegram': return LucideIcons.messageCircle;
      case 'games': return LucideIcons.gamepad2;
      case 'social': return LucideIcons.messageCircle;
      case 'productivity': return LucideIcons.briefcase;
      default: return LucideIcons.layoutGrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.subscription,
      builder: (context, subscription, _) {
        final bool isPremium = AppState.isPremium;

        return ValueListenableBuilder<String>(
          valueListenable: AppState.userName,
          builder: (context, storedName, _) {
            final userName  = storedName.isNotEmpty ? storedName : 'Нурислам';
            final userEmail = AppState.userEmail.value.isNotEmpty
                ? AppState.userEmail.value
                : 'admin@dophaminguard.com';

            return Scaffold(
              backgroundColor: const Color(0xFFFDF4FF),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(userName, userEmail, context),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildChartSection(),
                          const SizedBox(height: 24),
                          _buildUsersDirectory(),
                          const SizedBox(height: 32),
                          _buildMenuItem(
                            LucideIcons.crown,
                            isPremium ? 'Premium активен' : 'Получить Premium',
                            isPremium ? 'Спасибо за поддержку!' : 'Разблокируйте все функции',
                            !isPremium, true,
                            () => context.push('/premium'),
                          ),
                          _buildMenuItem(
                            LucideIcons.settings,
                            'Настройки',
                            'Уведомления, конфиденциальность',
                            false, false,
                            () => context.go('/settings'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              AppState.userName.value = '';
                              AppState.userEmail.value = '';
                              AppState.subscription.value = 'none';
                              context.go('/auth');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              foregroundColor: const Color(0xFFDC2626),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Выйти из аккаунта',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader(String userName, String userEmail, BuildContext ctx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 48),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 4),
            ),
            child: const Center(
                child: Icon(Icons.person, size: 40, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Text(userName,
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(userEmail,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 16)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  CHART SECTION — Неделя / День
  // ════════════════════════════════════════════════════════════════
  Widget _buildChartSection() {
    return StreamBuilder<List<ScreenTimeData>>(
      stream: _usageRepo.getUsageStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator()));
        }

        final items = snapshot.data ?? [];
        items.sort((a, b) =>
            _daysShort.indexOf(a.day).compareTo(_daysShort.indexOf(b.day)));

        // Заполняем 7 дней
        final weekData = List.generate(7, (i) {
          final dayStr = _daysShort[i];
          final match = items.where((e) => e.day == dayStr).toList();
          if (match.isNotEmpty) return match.first;
          return ScreenTimeData(
              id: '', day: dayStr, minutes: 0, category: 'N/A');
        });

        final totalMins =
            weekData.fold<int>(0, (sum, i) => sum + i.minutes);
        final avgMins =
            weekData.isNotEmpty ? (totalMins / 7).round() : 0;
        final maxMins = weekData.isNotEmpty
            ? weekData.map((e) => e.minutes).reduce((a, b) => a > b ? a : b)
            : 100;

        // Почасовые данные выбранного дня
        final hourlyData = _generateHourlyData(_selectedDayIndex);
        final dayTotalMins = hourlyData.fold<double>(0, (s, v) => s + v).round();
        final hourlyMax = hourlyData.reduce((a, b) => a > b ? a : b);

        // Категории выбранного дня
        final dayCategories = _generateDayCategories(_selectedDayIndex);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Переключатель ──
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _isWeekView ? 0 : 1,
                  children: const {
                    0: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Неделя',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600))),
                    1: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('День',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600))),
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isWeekView = val == 0;
                        if (!_isWeekView) {
                          _selectedDayIndex = DateTime.now().weekday - 1;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Заголовок ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isWeekView
                    ? _buildWeekHeader(avgMins)
                    : _buildDayHeader(dayTotalMins),
              ),
              const SizedBox(height: 24),

              // ── График ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isWeekView
                    ? _buildWeekChart(weekData, maxMins)
                    : _buildDayChart(hourlyData, hourlyMax),
              ),

              const SizedBox(height: 32),
              const Text('Топ приложений',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // ── Приложения ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isWeekView
                    ? _buildWeekApps(items, maxMins)
                    : _buildDayApps(dayCategories),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Заголовки ──────────────────────────────────────────────────
  Widget _buildWeekHeader(int avgMins) {
    return Column(
      key: const ValueKey('week-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('В СРЕДНЕМ ЗА ДЕНЬ',
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text('${avgMins ~/ 60} ч ${avgMins % 60} мин',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black)),
        const SizedBox(height: 4),
        const Text('На 12% меньше, чем на прошлой неделе',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDayHeader(int dayTotalMins) {
    return Column(
      key: const ValueKey('day-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_daysFull[_selectedDayIndex].toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text('${dayTotalMins ~/ 60} ч ${dayTotalMins % 60} мин',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black)),
        const SizedBox(height: 4),
        const Text('Детальная статистика за выбранный день',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  // ── НЕДЕЛЬНЫЙ ГРАФИК ──────────────────────────────────────────
  Widget _buildWeekChart(List<ScreenTimeData> weekData, int maxMins) {
    return SizedBox(
      key: const ValueKey('week-chart'),
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (barTouchResponse == null ||
                  barTouchResponse.spot == null) return;
              if (event is FlTapUpEvent) {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedDayIndex =
                      barTouchResponse.spot!.touchedBarGroupIndex;
                  _isWeekView = false;
                });
              }
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF34C759),
              tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} мин',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                );
              },
            ),
          ),
          alignment: BarChartAlignment.spaceEvenly,
          maxY: (maxMins > 0 ? maxMins : 100).toDouble() * 1.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32, // Увеличиваем место под текст
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < 7) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 8, // Отступ от графика
                      child: Text(_daysShort[idx],
                          style: TextStyle(
                            color:
                                idx == DateTime.now().weekday - 1
                                    ? Colors.black
                                    : Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight:
                                idx == DateTime.now().weekday - 1
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                          )),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            final isToday = i == DateTime.now().weekday - 1;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weekData[i].minutes.toDouble(),
                  color: isToday
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.2),
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── ПОЧАСОВОЙ ГРАФИК (ДЕНЬ) ───────────────────────────────────
  Widget _buildDayChart(List<double> hourlyData, double hourlyMax) {
    return SizedBox(
      key: ValueKey('day-chart-$_selectedDayIndex'),
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF34C759),
              tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} мин',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                );
              },
            ),
          ),
          alignment: BarChartAlignment.spaceEvenly,
          maxY: (hourlyMax > 0 ? hourlyMax : 60) * 1.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32, // Увеличиваем место под текст
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  // Показываем только каждые 6 часов
                  if (hour == 0 || hour == 6 || hour == 12 || hour == 18) {
                    final label = hour < 10 ? '0$hour:00' : '$hour:00';
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.black, // Текст теперь черный
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: List.generate(24, (hour) {
            // Определяем пиковые часы (19-22) для выделения цветом
            final isPeak = hour >= 19 && hour < 22;
            return BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: hourlyData[hour],
                  color: isPeak
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Приложения для недельного вида ──
  Widget _buildWeekApps(List<ScreenTimeData> items, int maxMins) {
    if (items.isEmpty) {
      return const Padding(
        key: ValueKey('week-apps-empty'),
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
            child: Text('Нет данных',
                style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      key: const ValueKey('week-apps'),
      children: items.take(3).map((item) {
        final ratio = maxMins > 0 ? item.minutes / maxMins : 0.0;
        return _buildAppRow(
            item.category, _getIconForCategory(item.category), item.minutes, ratio);
      }).toList(),
    );
  }

  // ── Приложения для дневного вида ──
  Widget _buildDayApps(List<Map<String, dynamic>> categories) {
    if (categories.isEmpty) {
      return Padding(
        key: ValueKey('day-apps-empty-$_selectedDayIndex'),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: const Center(
            child: Text('Нет данных',
                style: TextStyle(color: Colors.grey))),
      );
    }
    final topMins = categories.first['minutes'] as int;
    return Column(
      key: ValueKey('day-apps-$_selectedDayIndex'),
      children: categories.map((cat) {
        final ratio = topMins > 0 ? (cat['minutes'] as int) / topMins : 0.0;
        return _buildAppRow(
            cat['name'] as String, cat['icon'] as IconData, cat['minutes'] as int, ratio);
      }).toList(),
    );
  }

  Widget _buildAppRow(
      String name, IconData icon, int mins, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Text('${mins ~/ 60}ч ${mins % 60}м',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ЛИДЕРБОРД
  // ════════════════════════════════════════════════════════════════
  Widget _buildUsersDirectory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Лидеры недели',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StreamBuilder<List<UserModel>>(
          stream: _userRepo.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()));
            }
            final users = snapshot.data ?? [];
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length > 5 ? 5 : users.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final u = users[index];
                final rank = index + 1;

                Color rankColor = Colors.grey.shade400;
                if (rank == 1) rankColor = const Color(0xFFFFD700);
                if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                if (rank == 3) rankColor = const Color(0xFFCD7F32);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 32,
                          child: Text('#$rank',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rankColor,
                                  fontSize: 17))),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withOpacity(0.1),
                        child: const Icon(LucideIcons.user,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Text(u.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16))),
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text('${u.streak}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  MENU ITEM
  // ════════════════════════════════════════════════════════════════
  Widget _buildMenuItem(IconData icon, String label, String desc,
      bool highlight, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: highlight ? null : Colors.white,
            gradient: highlight ? AppGradients.primary : null,
            borderRadius: BorderRadius.circular(20),
            border:
                highlight ? null : Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color:
                      highlight ? Colors.white24 : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon,
                    color:
                        highlight ? Colors.white : Colors.grey.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: highlight
                                ? Colors.white
                                : Colors.black87)),
                    Text(desc,
                        style: TextStyle(
                            fontSize: 13,
                            color: highlight
                                ? Colors.white70
                                : Colors.grey)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  color:
                      highlight ? Colors.white : Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}