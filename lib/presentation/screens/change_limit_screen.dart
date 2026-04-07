import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';

class _AppLimit {
  final String name;
  final IconData icon;
  final Color color;
  double limitMinutes;

  _AppLimit({
    required this.name,
    required this.icon,
    required this.color,
    required this.limitMinutes,
  });
}

class ChangeLimitScreen extends StatefulWidget {
  const ChangeLimitScreen({super.key});

  @override
  State<ChangeLimitScreen> createState() => _ChangeLimitScreenState();
}

class _ChangeLimitScreenState extends State<ChangeLimitScreen> {
  late final List<_AppLimit> _apps;

  @override
  void initState() {
    super.initState();
    // Инициализируемся из глобального состояния
    final saved = AppState.appLimits.value;
    _apps = [
      _AppLimit(name: 'Instagram', icon: LucideIcons.instagram, color: const Color(0xFFE1306C), limitMinutes: saved.instagramLimit.toDouble()),
      _AppLimit(name: 'TikTok', icon: Icons.music_note, color: Colors.black87, limitMinutes: saved.tiktokLimit.toDouble()),
      _AppLimit(name: 'YouTube', icon: LucideIcons.youtube, color: const Color(0xFFFF0000), limitMinutes: saved.youtubeLimit.toDouble()),
    ];
  }

  static const double _minTotal = 30.0;
  static const double _maxTotal = 480.0;
  static const double _minApp = 5.0;
  static const double _maxApp = 240.0;

  // Вычисляется всегда как сумма ползунков приложений
  double get _totalMinutes =>
      _apps.fold(0.0, (sum, app) => sum + app.limitMinutes);

  // Вызывается когда пользователь двигает ОБЩИЙ ползунок:
  // пропорционально масштабирует все приложения
  void _onTotalChanged(double newTotal) {
    final oldTotal = _totalMinutes;
    if (oldTotal == 0) {
      // Если все нули — равномерно распределяем
      final share = newTotal / _apps.length;
      setState(() {
        for (final app in _apps) {
          app.limitMinutes = share.clamp(_minApp, _maxApp);
        }
      });
      return;
    }
    final ratio = newTotal / oldTotal;
    setState(() {
      for (final app in _apps) {
        app.limitMinutes = (app.limitMinutes * ratio).clamp(_minApp, _maxApp);
      }
    });
  }

  // Вызывается когда пользователь двигает ползунок ПРИЛОЖЕНИЯ:
  // просто обновляем значение, общий пересчитывается автоматически через get
  void _onAppChanged(_AppLimit app, double newValue) {
    setState(() {
      app.limitMinutes = newValue;
    });
  }

  String _formatTime(double minutes) {
    final h = minutes ~/ 60;
    final m = minutes.round() % 60;
    if (h == 0) return '${m}м';
    if (m == 0) return '${h}ч';
    return '${h}ч ${m}м';
  }

  void _saveAndPop() {
    // Сохраняем в глобальный AppState — дашборд обновится автоматически
    AppState.appLimits.value = AppLimitData(
      instagramLimit: _apps[0].limitMinutes.round(),
      tiktokLimit: _apps[1].limitMinutes.round(),
      youtubeLimit: _apps[2].limitMinutes.round(),
    );
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Лимиты сохранены!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalMinutes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Обернул в Expanded — fix overflow
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Лимиты экранного времени',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Установите дневные ограничения',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Summary chip — показывает живую сумму
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Итого в день: ${_formatTime(total)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Общий ползунок ──
                  _SectionHeader(
                    icon: LucideIcons.timer,
                    title: 'Общий дневной лимит',
                    subtitle: 'Масштабирует все приложения пропорционально',
                  ),
                  const SizedBox(height: 12),
                  _SliderCard(
                    value: total.clamp(_minTotal, _maxTotal),
                    min: _minTotal,
                    max: _maxTotal,
                    color: AppColors.primary,
                    label: _formatTime(total),
                    minLabel: _formatTime(_minTotal),
                    maxLabel: _formatTime(_maxTotal),
                    onChanged: _onTotalChanged,
                    formatTime: _formatTime,
                  ),

                  const SizedBox(height: 28),

                  // ── Заголовок приложений ──
                  const Text(
                    'Лимиты по приложениям',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Сумма = общий лимит выше',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),

                  // ── Карточки приложений ──
                  ..._apps.map((app) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AppLimitCard(
                      app: app,
                      formatTime: _formatTime,
                      onChanged: (v) => _onAppChanged(app, v),
                    ),
                  )),

                  const SizedBox(height: 12),

                  // ── Info box ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info, color: AppColors.primary, size: 16),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'При изменении общего ползунка все приложения масштабируются пропорционально. При изменении отдельного приложения — общая сумма обновляется автоматически.',
                            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Кнопка сохранить ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            color: const Color(0xFFF8F7FF),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveAndPop,
                  icon: const Icon(LucideIcons.check, size: 20),
                  label: const Text(
                    'Сохранить лимиты',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Переиспользуемые виджеты ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderCard extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Color color;
  final String label;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<double> onChanged;
  final String Function(double) formatTime;

  const _SliderCard({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.label,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Время', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.15),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(maxLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppLimitCard extends StatelessWidget {
  final _AppLimit app;
  final String Function(double) formatTime;
  final ValueChanged<double> onChanged;

  const _AppLimitCard({
    required this.app,
    required this.formatTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: app.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(app.icon, color: app.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(app.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formatTime(app.limitMinutes),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: app.color,
              inactiveTrackColor: app.color.withOpacity(0.12),
              thumbColor: app.color,
              overlayColor: app.color.withOpacity(0.08),
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: app.limitMinutes.clamp(5.0, 240.0),
              min: 5,
              max: 240,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('5м', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Text('4ч', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
