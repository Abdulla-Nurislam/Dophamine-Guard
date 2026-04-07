import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  static const List<int> _durations = [15, 25, 45, 60, 90, 120];
  int _selectedMinutes = 25;

  bool _isRunning = false;
  int _secondsLeft = 0;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _history = [
    {'minutes': 25, 'ago': '2 часа назад', 'completed': true},
    {'minutes': 45, 'ago': 'Вчера, 18:30', 'completed': true},
    {'minutes': 15, 'ago': 'Вчера, 10:00', 'completed': false},
  ];

  int get _totalSeconds => _selectedMinutes * 60;
  double get _progress =>
      _isRunning ? 1.0 - (_secondsLeft / _totalSeconds) : 0.0;

  String get _timeLabel {
    if (!_isRunning) return '${_selectedMinutes.toString().padLeft(2, '0')}:00';
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startSession() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _secondsLeft = _totalSeconds;
    });
    _pulseController.stop();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        _onComplete();
      }
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _pulseController.repeat(reverse: true);
    _showStopDialog();
  }

  void _onComplete() {
    HapticFeedback.heavyImpact();
    setState(() => _isRunning = false);
    _pulseController.repeat(reverse: true);
    _showCompletedDialog();
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Прервать сессию?', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Ты прошёл часть пути. Остановиться сейчас?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Продолжить'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Остановить'),
          ),
        ],
      ),
    );
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.trophy, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Отличная работа!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Ты провёл $_selectedMinutes минут в фокусе без соцсетей',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${(_selectedMinutes ~/ 5) * 5} очков к стрику',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Закрыть',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      body: Column(
        children: [
          // ── Gradient Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
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
                        child: const Icon(LucideIcons.arrowLeft,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Фокус-режим',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('Блокируй соцсети на время сессии',
                              style: TextStyle(
                                  color: Color(0xFFF3E8FF), fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.crown,
                              color: Colors.amber.shade300, size: 14),
                          const SizedBox(width: 4),
                          const Text('Premium',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  children: [
                    _headerStat('3', 'Сессий\nсегодня'),
                    const SizedBox(width: 20),
                    _headerStat('95', 'Минут\nв фокусе'),
                    const SizedBox(width: 20),
                    _headerStat('7', 'Стрик\nдней'),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── Timer circle card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _isRunning
                              ? const AlwaysStoppedAnimation(1.0)
                              : _pulseAnim,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.06),
                                  ),
                                ),
                                // Progress ring
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: CircularProgressIndicator(
                                    value: _isRunning ? _progress : 0,
                                    strokeWidth: 8,
                                    backgroundColor:
                                        AppColors.primary.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isRunning
                                          ? AppColors.success
                                          : AppColors.primary,
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                // Center text
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isRunning
                                          ? LucideIcons.brain
                                          : LucideIcons.zap,
                                      color: _isRunning
                                          ? AppColors.success
                                          : AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _timeLabel,
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMain,
                                        letterSpacing: 2,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _isRunning ? 'в фокусе' : 'готов',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Duration selector
                        if (!_isRunning) ...[
                          const SizedBox(height: 24),
                          const Text('Выберите длительность',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: _durations.map((min) {
                                final selected = min == _selectedMinutes;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedMinutes = min);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 9),
                                    decoration: BoxDecoration(
                                      gradient: selected
                                          ? AppGradients.primary
                                          : null,
                                      color: selected
                                          ? null
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$min мин',
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        if (_isRunning) ...[
                          const SizedBox(height: 20),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.shieldCheck,
                                    color: AppColors.success, size: 18),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Соцсети заблокированы. Держись!',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Start / Stop button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _isRunning
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFEF4444),
                                          Color(0xFFDC2626)
                                        ],
                                      )
                                    : AppGradients.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRunning
                                            ? AppColors.error
                                            : AppColors.primary)
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isRunning ? _stopSession : _startSession,
                                icon: Icon(
                                    _isRunning
                                        ? LucideIcons.square
                                        : LucideIcons.play,
                                    size: 18),
                                label: Text(
                                  _isRunning
                                      ? 'Прервать сессию'
                                      : 'Начать фокус-сессию',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Benefits ──
                  if (!_isRunning) ...[
                    _benefitRow(LucideIcons.shieldOff,
                        'Блокировка соцсетей во время сессии',
                        const Color(0xFF8B5CF6)),
                    const SizedBox(height: 10),
                    _benefitRow(LucideIcons.flame,
                        'Засчитывается в дневной стрик',
                        const Color(0xFFF97316)),
                    const SizedBox(height: 10),
                    _benefitRow(LucideIcons.barChart2,
                        'Детальная аналитика фокус-сессий',
                        const Color(0xFFEC4899)),
                    const SizedBox(height: 24),
                  ],

                  // ── History ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Недавние сессии',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain)),
                      Text('${_history.length} сессий',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._history.map((s) => _buildHistoryItem(s)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFFF3E8FF), fontSize: 11, height: 1.3)),
      ],
    );
  }

  Widget _benefitRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textMain, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> s) {
    final completed = s['completed'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed ? LucideIcons.checkCircle : LucideIcons.xCircle,
              color: completed ? AppColors.success : AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s['minutes']} минут фокуса',
                    style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w600)),
                Text(s['ago'] as String,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              completed ? 'Завершено' : 'Прервано',
              style: TextStyle(
                color: completed ? AppColors.success : AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
