import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../core/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock Settings State
  final Map<String, bool> _notifications = {
    'limit': true,
    'mood': true,
    'awards': true,
    'reports': false,
    'motivate': true,
  };

  void _showDeleteAccountDialog() {
    int timeLeft = 5;
    Timer? timer;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (timeLeft > 0) {
                setModalState(() => timeLeft--);
              } else {
                t.cancel();
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Удалить аккаунт?'),
                ],
              ),
              content: const Text(
                'Это действие необратимо. Все ваши данные, достижения и прогресс будут удалены навсегда.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: timeLeft == 0 ? () {
                    Navigator.pop(context);
                    context.go('/auth');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.red.withOpacity(0.3),
                  ),
                  child: Text(timeLeft > 0 ? 'Удалить ($timeLeft)' : 'Удалить навсегда'),
                ),
              ],
            );
          }
        );
      },
    ).then((_) => timer?.cancel());
  }

  void _showAppManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(LucideIcons.smartphone, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Управление приложениями', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Выберите приложения для контроля и установите лимиты использования.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _managedAppItem('Instagram', '📸', 60, true),
                  _managedAppItem('TikTok', '🎵', 45, true),
                  _managedAppItem('YouTube', '▶️', 30, true),
                  _managedAppItem('Telegram', '✈️', 120, false),
                  _managedAppItem('VK', '🔵', 60, false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSupportSheet(ctx),
    );
  }

  Widget _buildSupportSheet(BuildContext sheetContext) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(LucideIcons.mail, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Связаться с нами',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
              'Опишите вашу проблему или предложение. Мы ответим вам на email в течение 24 часов.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ваше сообщение...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(sheetContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Сообщение отправлено! Мы свяжемся с вами.')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Отправить'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showFaqModal() {
    // Save a reference to the outer (screen) context BEFORE opening the sheet.
    // The inner builder context becomes invalid once the sheet is dismissed.
    final outerCtx = context;

    final faqItems = [
      {'q': 'Как работает отслеживание экранного времени?', 'a': 'DophamineGuard показывает мок-данные для демонстрации. В реальном приложении интеграция с Digital Wellbeing (Android) или Screen Time (iOS) позволяет получать точные данные о каждом приложении.'},
      {'q': 'Можно ли изменить лимиты для конкретных приложений?', 'a': 'Да! В разделе «Управление приложениями» вы можете задать индивидуальный дневной лимит для каждого приложения. После достижения лимита появляется экран блокировки.'},
      {'q': 'Что такое квиз за дополнительное время?', 'a': 'Если вы превысили лимит, вы можете заработать до 25 минут дополнительного времени, ответив правильно на 5 вопросов по теме цифровой осознанности. Это помогает сделать использование телефона более вдумчивым.'},
      {'q': 'Чем отличается Premium от бесплатной версии?', 'a': 'Premium открывает: AI-анализ ваших паттернов, программы «Средний» и «Интенсивный», еженедельные PDF-отчёты, расширенную статистику по всем приложениям и личные рекомендации.'},
      {'q': 'Как работают достижения и стрики?', 'a': 'Стрик увеличивается каждый день, когда вы не превышаете установленный лимит. Достижения разблокируются при выполнении определённых условий: первый день, 7 дней подряд, 10 квизов и другие.'},
      {'q': 'Можно ли изменить программу детокса?', 'a': 'Да, зайдите в «Профиль» → «Изменить цель» или нажмите на быстрое действие на дашборде. Помните: смена на «Средний» или «Интенсивный» требует Premium-подписки.'},
      {'q': 'Как удалить данные о конкретном приложении?', 'a': 'В разделе «Управление приложениями» (Настройки → Приложение) нажмите на «−» рядом с нужным приложением, чтобы убрать его из отслеживания.'},
      {'q': 'Что происходит с данными при удалении аккаунта?', 'a': 'Все ваши данные (история, достижения, настройки) безвозвратно удаляются. Экспортируйте их через Профиль перед удалением, если хотите сохранить статистику.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.helpCircle, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text('Помощь и FAQ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: faqItems.length,
                separatorBuilder: (c, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) => ExpansionTile(
                  title: Text(faqItems[i]['q']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  collapsedBackgroundColor: Colors.grey.shade50,
                  backgroundColor: Colors.purple.shade50,
                  childrenPadding: const EdgeInsets.all(16),
                  children: [Text(faqItems[i]['a']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)]), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Не нашли ответ на свой вопрос?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (outerCtx.mounted) {
                          showModalBottomSheet(
                            context: outerCtx,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _buildSupportSheet(outerCtx),
                          );
                        }
                      });
                    },
                    icon: const Icon(LucideIcons.mail, size: 16),
                    label: const Text('Написать в поддержку'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _managedAppItem(String name, String emoji, int mins, bool initialTracked) {
    bool isTracked = initialTracked;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Лимит: $mins мин', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: isTracked,
                  onChanged: (v) => setModalState(() => isTracked = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text('Настройки', style: TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          }, 
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSection('УВЕДОМЛЕНИЯ', [
              _switchTile('Предупреждение о лимите', 'За 15 минут до исчерпания', _notifications['limit']!, (v) => setState(() => _notifications['limit'] = v)),
              _switchTile('Ежедневное напоминание', 'Проверка настроения по утрам', _notifications['mood']!, (v) => setState(() => _notifications['mood'] = v)),
              _switchTile('Разблокировка достижений', 'Новые рекорды и награды', _notifications['awards']!, (v) => setState(() => _notifications['awards'] = v)),
              ValueListenableBuilder<String>(
                valueListenable: AppState.subscription,
                builder: (context, value, child) {
                  return _switchTile('Еженедельный отчёт', 'Детальная аналитика', _notifications['reports']!, (v) {
                    if (AppState.isPremium) {
                      setState(() => _notifications['reports'] = v);
                    } else {
                      context.push('/premium');
                    }
                  }, isPremium: !AppState.isPremium);
                }
              ),
            ]),
            const SizedBox(height: 32),
            _buildSection('ПРИЛОЖЕНИЕ', [
              _linkTile(LucideIcons.smartphone, 'Управление приложениями', 'Лимиты и список блокировки', _showAppManager),
              _linkTile(LucideIcons.helpCircle, 'Помощь и FAQ', 'Ответы на частые вопросы', _showFaqModal),
            ]),
            const SizedBox(height: 32),
            _buildSection('КОНФИДЕНЦИАЛЬНОСТЬ', [
              _linkTile(LucideIcons.shield, 'Конфиденциальность данных', 'Как мы защищаем вас', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открывается ссылка: https://dophamineguard.com/privacy')));
              }),
              _linkTile(LucideIcons.fileText, 'Условия использования', 'Соглашение пользователя', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открывается ссылка: https://dophamineguard.com/terms')));
              }),
            ]),
            const SizedBox(height: 32),
            _buildSection('ПОДДЕРЖКА', [
              _linkTile(LucideIcons.mail, 'Написать нам', 'support@dophamineguard.com', _showSupportModal),
              _linkTile(LucideIcons.star, 'Оценить приложение', 'Нам важно ваше мнение', () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Оцените DophamineGuard'),
                    content: const Text('Вам нравится наше приложение? Пожалуйста, уделите минутку, чтобы оставить отзыв на платформе!'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Позже', style: TextStyle(color: Colors.grey))),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Переход в магазин приложений...')));
                        }, 
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Оценить')
                      ),
                    ],
                  ),
                );
              }),
            ]),
            const SizedBox(height: 32),
            _buildSection('ОПАСНАЯ ЗОНА', [
              _linkTile(LucideIcons.trash2, 'Удалить аккаунт', 'Все данные будут удалены навсегда', _showDeleteAccountDialog, isDanger: true),
            ]),
            const SizedBox(height: 48),
            const Text(
              'DophamineGuard v1.0.0\n© 2026 Все права защищены.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, Function(bool) onChanged, {bool isPremium = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)), child: Text('Pro', style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  ],
                ),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDanger ? Colors.red.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: isDanger ? Colors.red : Colors.grey.shade700)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDanger ? Colors.red : Colors.black)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(LucideIcons.chevronRight, size: 16, color: isDanger ? Colors.red.withOpacity(0.5) : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
