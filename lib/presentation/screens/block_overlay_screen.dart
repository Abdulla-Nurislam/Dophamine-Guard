import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

class BlockOverlayScreen extends StatelessWidget {
  const BlockOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5), // Indigo background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.shieldAlert, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Лимит исчерпан',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Сделайте глубокий вдох. Вы израсходовали лимит для всех отслеживаемых приложений на сегодня.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ваш стрик в безопасности',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.whatshot, size: 18, color: Colors.orangeAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Вы можете разблокировать на 15 минут, если пройдете тест на осознанность',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.push('/quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4F46E5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Пройти тест и разблокировать', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/dashboard');
                  }
                },
                child: const Text('Вернуться на главную', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
