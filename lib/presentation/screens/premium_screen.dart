import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  void _simulatePayment(BuildContext context, String planName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!dialogCtx.mounted) return;
          Navigator.pop(dialogCtx);
          
          AppState.subscription.value = planName.toLowerCase();
          
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Подписка "$planName" успешно оформлена! 🎉'),
              backgroundColor: Colors.green,
            )
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.purple),
              const SizedBox(height: 24),
              Text('Оформление "$planName"...', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Пожалуйста, подождите', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppState.subscription,
      builder: (context, subscription, child) {
        final bool isPremiumPlan = subscription == 'premium';
        final bool isLifetime = subscription == 'lifetime';

        return Scaffold(
          backgroundColor: const Color(0xFF581C87), // from-purple-900
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF581C87), // purple-900
              Color(0xFF6B21A8), // purple-800
              Color(0xFF9D174D), // pink-800
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/dashboard');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text('Назад', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.crown, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Разблокируйте полный потенциал',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите план для максимальных результатов',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE9D5FF), fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Benefits Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildBenefitCard(LucideIcons.brain, 'AI-анализ привычек', 'Умные рекомендации на основе вашего поведения'),
                    _buildBenefitCard(LucideIcons.trendingUp, 'Расширенная статистика', 'Детальные графики и аналитика прогресса'),
                    _buildBenefitCard(LucideIcons.sparkles, 'Все программы', 'Доступ к интенсивным программам детокса'),
                    _buildBenefitCard(LucideIcons.download, 'Экспорт данных', 'Сохраняйте статистику в PDF и CSV'),
                  ],
                ),
                const SizedBox(height: 32),

                // Plans
                if (!isPremiumPlan && !isLifetime) ...[
                  _buildPlanCard(
                    context,
                    title: 'Бесплатно',
                    price: '0₽',
                    period: 'навсегда',
                    features: [
                      const _Feature(text: 'Базовый трекинг использования', included: true),
                      const _Feature(text: 'Программа "Легкий"', included: true),
                      const _Feature(text: '7 дней истории', included: true),
                      const _Feature(text: 'Базовые достижения', included: true),
                      const _Feature(text: 'AI-анализ привычек', included: false),
                      const _Feature(text: 'Все программы детокса', included: false),
                      const _Feature(text: 'Расширенная статистика', included: false),
                    ],
                    buttonText: 'Текущий план',
                    onTap: () {},
                    buttonDisabled: true,
                  ),
                  const SizedBox(height: 16),
                ],
                if (!isLifetime) ...[
                  _buildPlanCard(
                    context,
                    title: 'Premium',
                    price: '₽349',
                    period: 'в месяц',
                    isPopular: true,
                    features: [
                      const _Feature(text: 'Все из бесплатной версии', included: true),
                      const _Feature(text: 'AI-анализ и рекомендаци', included: true),
                      const _Feature(text: 'Все программы детокса', included: true),
                      const _Feature(text: 'Неограниченная история', included: true),
                      const _Feature(text: 'Расширенная аналитика', included: true),
                      const _Feature(text: 'Экспорт данных PDF/CSV', included: true),
                    ],
                    buttonText: isPremiumPlan ? 'Оформлено' : 'Подписаться',
                    onTap: isPremiumPlan ? () {} : () => _simulatePayment(context, 'Premium'),
                    buttonDisabled: isPremiumPlan,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildPlanCard(
                  context,
                  title: 'Lifetime',
                  price: '₽2990',
                  period: 'навсегда',
                  badge: 'Лучшее предложение',
                  features: [
                    const _Feature(text: 'Все Premium функции', included: true),
                    const _Feature(text: 'Единоразовый платеж', included: true),
                    const _Feature(text: 'Все будущие обновления', included: true),
                    const _Feature(text: 'Пожизненная поддержка', included: true),
                  ],
                  buttonText: isLifetime ? 'Оформлено' : (isPremiumPlan ? 'Улучшить до Lifetime' : 'Подписаться'),
                  onTap: isLifetime ? () {} : () => _simulatePayment(context, 'Lifetime'),
                  buttonDisabled: isLifetime,
                ),

                const SizedBox(height: 24),
                const Text(
                  '7 дней бесплатно для Premium\nОтмена в любое время • Безопасная оплата',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE9D5FF), fontSize: 13),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
      }
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFBBF24), size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Expanded(child: Text(desc, style: const TextStyle(color: Color(0xFFE9D5FF), fontSize: 10))),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<_Feature> features,
    required String buttonText,
    required VoidCallback onTap,
    bool isPopular = false,
    String? badge,
    bool buttonDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPopular ? Colors.white : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: isPopular ? Border.all(color: const Color(0xFFFBBF24), width: 4) : null,
        boxShadow: isPopular ? [const BoxShadow(color: Colors.black26, blurRadius: 20)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(width: 8),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFBBF24), borderRadius: BorderRadius.circular(12)),
                  child: Text(badge, style: const TextStyle(fontSize: 10, color: Color(0xFF78350F), fontWeight: FontWeight.bold)),
                ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Популярно', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain)),
              const SizedBox(width: 4),
              Text(period, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: f.included ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    f.included ? Icons.check : Icons.close,
                    size: 14,
                    color: f.included ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    f.text,
                    style: TextStyle(
                      color: f.included ? AppColors.textMain : AppColors.inactiveNav,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: buttonDisabled ? null : onTap,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                disabledForegroundColor: Colors.white,
                backgroundColor: isPopular ? null : (title == 'Lifetime' ? Colors.orange : Colors.grey.shade200),
                foregroundColor: isPopular ? Colors.white : (title == 'Lifetime' ? Colors.white : AppColors.textMain),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: isPopular && !buttonDisabled ? 4 : 0,
              ).copyWith(
                backgroundColor: isPopular && !buttonDisabled ? WidgetStateProperty.all(Colors.transparent) : null,
                shadowColor: isPopular && !buttonDisabled ? WidgetStateProperty.all(Colors.transparent) : null,
              ),
              child: isPopular && !buttonDisabled
                  ? Ink(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: builderText(buttonText, true),
                      ),
                    )
                  : builderText(buttonText, title == 'Lifetime' || buttonDisabled),
            ),
          ),
        ],
      ),
    );
  }

  Widget builderText(String text, bool light) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: light ? Colors.white : AppColors.textMain, fontSize: 16)),
    );
  }
}

class _Feature {
  final String text;
  final bool included;
  const _Feature({required this.text, required this.included});
}
