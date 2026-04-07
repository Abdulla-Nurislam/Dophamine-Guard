import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

// ── Quick Stat Card ───────────────────────────────────────────
class QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const QuickStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: iconColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── App Usage Card ───────────────────────────────────────────
class AppUsageCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int usedMinutes;
  final int limitMinutes;

  const AppUsageCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.usedMinutes,
    required this.limitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final percent = usedMinutes / limitMinutes;
    final isOver = usedMinutes > limitMinutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surface, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Лимит: $limitMinutes мин',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$usedMinutes мин',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isOver ? AppColors.error : AppColors.textMain,
                    ),
                  ),
                  Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              color: isOver ? AppColors.error : null,
              minHeight: 8,
              // Use gradient if possible (custom painter or stack)
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mood Check Card (Compact) ──────────────────────────────────
class DashboardMoodCheckCard extends StatefulWidget {
  final Function(String) onMoodSelect;
  const DashboardMoodCheckCard({super.key, required this.onMoodSelect});

  @override
  State<DashboardMoodCheckCard> createState() => _DashboardMoodCheckCardState();
}

class _DashboardMoodCheckCardState extends State<DashboardMoodCheckCard> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _selectedId == null ? _buildPicker() : _buildConfirmed(),
    );
  }

  Widget _buildPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text('🌅', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Как ваше настроение?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('Ежедневный чек-ин помогает нам', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _MoodItem(emoji: '😊', label: 'Отлично', onTap: () => _select('great'))),
              const SizedBox(width: 8),
              Expanded(child: _MoodItem(emoji: '🙂', label: 'Хорошо', onTap: () => _select('good'))),
              const SizedBox(width: 8),
              Expanded(child: _MoodItem(emoji: '😐', label: 'Нормально', onTap: () => _select('okay'))),
              const SizedBox(width: 8),
              Expanded(child: _MoodItem(emoji: '😔', label: 'Не очень', onTap: () => _select('bad'))),
            ],
          ),
        ],
      ),
    );
  }

  void _select(String id) {
    setState(() => _selectedId = id);
    Future.delayed(const Duration(milliseconds: 1800), () => widget.onMoodSelect(id));
  }

  Widget _buildConfirmed() {
    // Simple confirmed state
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Text('✨', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Спасибо! Мы учтем ваше настроение.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _MoodItem({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
