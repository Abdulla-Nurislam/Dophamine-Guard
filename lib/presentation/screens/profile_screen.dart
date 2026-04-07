import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isWeekView = true;
  int _selectedDayIndex = 6; // Sunday

  // Weekly usage data (matches QuizRunner data style from React)
  final List<Map<String, dynamic>> _weekData = [
    {'day': 'Пн', 'mins': 120, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 60},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 40},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 20},
    ]},
    {'day': 'Вт', 'mins': 145, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 80},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 50},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 15},
    ]},
    {'day': 'Ср', 'mins': 90, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 40},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 30},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 20},
    ]},
    {'day': 'Чт', 'mins': 110, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 50},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 40},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 20},
    ]},
    {'day': 'Пт', 'mins': 180, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 100},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 60},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 20},
    ]},
    {'day': 'Сб', 'mins': 210, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 120},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 70},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 20},
    ]},
    {'day': 'Вс', 'mins': 145, 'apps': [
      {'name': 'Instagram', 'icon': '📸', 'mins': 85},
      {'name': 'TikTok', 'icon': '🎵', 'mins': 45},
      {'name': 'YouTube', 'icon': '▶️', 'mins': 15},
    ]},
  ];

  // Deterministic hourly breakdown (24 buckets) based on total minutes
  List<int> _hourlyFor(int totalMins, int seed) {
    var s = seed;
    int next() {
      s = (s * 16807 + 11) % 2147483647;
      return (s & 0xffff);
    }

    final weights = List.generate(24, (h) {
      final r = next() / 65535.0;
      if (h >= 0 && h < 6)  return 0.02 + r * 0.03;
      if (h >= 6 && h < 8)  return 0.2  + r * 0.15;
      if (h >= 8 && h < 10) return 0.6  + r * 0.3;
      if (h >= 10 && h < 12) return 0.4 + r * 0.25;
      if (h >= 12 && h < 14) return 0.7 + r * 0.3;
      if (h >= 14 && h < 17) return 0.3 + r * 0.2;
      if (h >= 17 && h < 19) return 0.5 + r * 0.3;
      if (h >= 19 && h < 22) return 0.8 + r * 0.2;
      return 0.15 + r * 0.1;
    });
    final total = weights.fold(0.0, (a, b) => a + b);
    return weights.map((w) => ((w / total) * totalMins).round()).toList();
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
            return ValueListenableBuilder<String>(
              valueListenable: AppState.userEmail,
              builder: (context, storedEmail, _) {
                final userName  = storedName.isNotEmpty  ? storedName  : 'Нурислам';
                final userEmail = storedEmail.isNotEmpty ? storedEmail : 'admin@dophaminguard.com';

                final selectedDay = _weekData[_selectedDayIndex];
                final hourlyData  = _hourlyFor(selectedDay['mins'] as int, _selectedDayIndex * 137 + 1000);
                final maxHourly   = hourlyData.reduce((a, b) => a > b ? a : b);

                return Scaffold(
                  backgroundColor: const Color(0xFFFDF4FF),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Header ──────────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                          decoration: const BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft:  Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 96, height: 96,
                                decoration: BoxDecoration(
                                  color:  Colors.white.withOpacity(0.2),
                                  shape:  BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                                ),
                                child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
                              ),
                              const SizedBox(height: 16),
                              Text(userName, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Column(
                                  children: [
                                    Text('Программа детокса', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text('🎯 Легкий', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text('Лимит: 180 мин/день', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // ── Chart ────────────────────────────────────
                              _buildChart(selectedDay, hourlyData, maxHourly),
                              const SizedBox(height: 24),

                              // ── Stats Grid ───────────────────────────────
                              Row(children: [
                                _buildStatBox(LucideIcons.calendar, 'Дней детокса',    '18',   const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                                const SizedBox(width: 12),
                                _buildStatBox(LucideIcons.clock,    'Часов сэкономлено', '45ч', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                _buildStatBox(LucideIcons.target, 'Текущий стрик', '5 🔥', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
                                const SizedBox(width: 12),
                                _buildStatBox(LucideIcons.award, 'Лучший стрик',  '7',    const Color(0xFFFAF5FF), const Color(0xFF9333EA)),
                              ]),
                              const SizedBox(height: 32),

                              // ── Menu ─────────────────────────────────────
                              _buildMenuItem(
                                LucideIcons.crown,
                                isPremium ? 'Premium активен' : 'Получить Premium',
                                isPremium ? 'Спасибо за поддержку!' : 'Разблокируйте все функции',
                                !isPremium, true,
                                () => context.push('/premium'),
                              ),
                              _buildMenuItem(
                                LucideIcons.download, 'Экспорт данных', 'PDF / CSV',
                                false, false,
                                () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Данные сохранены в загрузки!')),
                                ),
                                badge: isPremium ? null : 'Premium',
                              ),
                              _buildMenuItem(
                                LucideIcons.share2, 'Поделиться прогрессом', 'Вдохновите друзей',
                                false, false,
                                () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Прогресс скопирован в буфер обмена!')),
                                ),
                              ),
                              _buildMenuItem(
                                LucideIcons.settings, 'Настройки', 'Уведомления, конфиденциальность',
                                false, false,
                                () => context.go('/settings'),
                              ),

                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  AppState.userName.value  = '';
                                  AppState.userEmail.value = '';
                                  AppState.subscription.value = 'none';
                                  context.go('/auth');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  foregroundColor: const Color(0xFFDC2626),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Выйти из аккаунта'),
                              ),
                              const SizedBox(height: 32),

                              // ── Community (Week 10 Firestore Task) ────────
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Наше комьюнити', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).limit(5).snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return const Text('Пока нет пользователей', style: TextStyle(color: Colors.grey));
                                    }
                                    
                                    return ListView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: snapshot.data!.docs.map((doc) {
                                        final data = doc.data() as Map<String, dynamic>;
                                        final name = data.containsKey('name') ? data['name'] : 'Аноним';
                                        final streak = data.containsKey('streak') ? data['streak'] : 0;
                                        
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.primary.withOpacity(0.1),
                                            child: const Icon(LucideIcons.user, color: AppColors.primary, size: 20),
                                          ),
                                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text('Стрик: $streak дней', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                          trailing: const Text('🔥', style: TextStyle(fontSize: 20)),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
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
      },
    );
  }

  // ── Unified chart widget ─────────────────────────────────────────────────────
  Widget _buildChart(
    Map<String, dynamic> selectedDay,
    List<int> hourlyData,
    int maxHourly,
  ) {
    final int maxMins = _weekData.map((d) => d['mins'] as int).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ЭКРАННОЕ ВРЕМЯ', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  if (_isWeekView)
                    Text(
                      '${((_weekData.fold(0, (s, d) => s + (d['mins'] as int)) ~/ _weekData.length) ~/ 60)}ч '
                      '${(_weekData.fold(0, (s, d) => s + (d['mins'] as int)) ~/ _weekData.length) % 60}м',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      '${(selectedDay['mins'] as int) ~/ 60}ч ${(selectedDay['mins'] as int) % 60}м',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              // Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    _toggleBtn('День',   !_isWeekView, () => setState(() => _isWeekView = false)),
                    _toggleBtn('Неделя',  _isWeekView, () => setState(() => _isWeekView = true)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── WEEK view: 7 vertical bars ──────────────────────────────────
          if (_isWeekView) ...[
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_weekData.length, (i) {
                  final d = _weekData[i];
                  final barH = ((d['mins'] as int) / maxMins) * 120;
                  final isSel = i == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDayIndex = i;
                      _isWeekView = false; // switch to day view on tap
                    }),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 28, height: barH.toDouble(),
                          decoration: BoxDecoration(
                            gradient: isSel ? AppGradients.card : null,
                            color:    isSel ? null : Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d['day'] as String,
                          style: TextStyle(fontSize: 12, color: isSel ? AppColors.primary : Colors.grey)),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            Text('Ср. за неделю · нажмите на столбик для детализации',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ] else ...[
          // ── DAY view: 24 hourly bars ────────────────────────────────────
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (h) {
                  final mins = hourlyData[h];
                  final barH = maxHourly > 0 ? (mins / maxHourly) * 120.0 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: barH.clamp(0.0, 120.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                                begin: Alignment.bottomCenter,
                                end:   Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),
            // Hour labels: 00 06 12 18 23
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['00', '06', '12', '18', '23'].map((h) =>
                Text(h, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ).toList(),
            ),
          ],

          const SizedBox(height: 20),
          // ── Top apps for selected day ─────────────────────────────────
          const Text('Топ приложений', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          ...(selectedDay['apps'] as List).map((app) {
            final double ratio = (app['mins'] as int) / (selectedDay['mins'] as int);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${app['icon']} ${app['name']}', style: const TextStyle(fontSize: 14)),
                      Text('${(app['mins'] as int) ~/ 60} ч ${(app['mins'] as int) % 60} м',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio, minHeight: 6,
                      backgroundColor: Colors.purple.withOpacity(0.05),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.black : Colors.grey)),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, Color bgColor, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, String desc, bool highlight, bool isActive, VoidCallback onTap, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:    highlight ? null : Colors.white,
            gradient: highlight ? AppGradients.primary : null,
            borderRadius: BorderRadius.circular(20),
            border: highlight ? null : Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: highlight ? Colors.white24 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: highlight ? Colors.white : Colors.grey.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: highlight ? Colors.white : Colors.black)),
                    Row(
                      children: [
                        Flexible(child: Text(desc,
                          style: TextStyle(fontSize: 13, color: highlight ? Colors.white70 : Colors.grey),
                          overflow: TextOverflow.ellipsis)),
                        if (badge != null) ...[const SizedBox(width: 6), const Text('👑', style: TextStyle(fontSize: 12))],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: highlight ? Colors.white : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
