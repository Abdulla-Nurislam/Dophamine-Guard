import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> _questions = [
    Question(
      id: 1,
      question: "Сколько времени в среднем человек тратит на соцсети в день?",
      options: ["1-2 часа", "3-4 часа", "5-6 часов", "7+ часов"],
      correctAnswer: 2,
      explanation: "Исследования показывают, что средний пользователь тратит около 2.5 часов в день на соцсети.",
    ),
    Question(
      id: 2,
      question: 'Что такое "дофаминовая детоксикация"?',
      options: [
        "Полный отказ от технологий",
        "Осознанное сокращение стимулов",
        "Диета для мозга",
        "Медицинская процедура",
      ],
      correctAnswer: 1,
      explanation: "Дофаминовая детоксикация - это осознанное сокращение высокостимулирующих активностей для перезагрузки системы вознаграждения мозга.",
    ),
    Question(
      id: 3,
      question: "Какой эффект оказывает чрезмерное использование соцсетей?",
      options: [
        "Улучшение памяти",
        "Снижение концентрации",
        "Повышение продуктивности",
        "Улучшение сна",
      ],
      correctAnswer: 1,
      explanation: "Чрезмерное использование соцсетей связано со снижением концентрации, ухудшением сна и повышенной тревожностью.",
    ),
    Question(
      id: 4,
      question: "Сколько времени нужно мозгу для формирования новой привычки?",
      options: ["7 дней", "21 день", "66 дней", "90 дней"],
      correctAnswer: 2,
      explanation: "В среднем требуется 66 дней для формирования новой привычки, но это может варьироваться от 18 до 254 дней.",
    ),
    Question(
      id: 5,
      question: "Что лучше всего помогает в цифровой детоксикации?",
      options: [
        "Резкий отказ от всего",
        "Постепенное сокращение",
        "Замена одного на другое",
        "Ничего не менять",
      ],
      correctAnswer: 1,
      explanation: "Постепенное сокращение более эффективно, так как позволяет мозгу адаптироваться без стресса и срывов.",
    ),
  ];

  int _currentIndex = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _quizCompleted = false;
  bool _timedOut = false;
  int _timeLeft = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        setState(() => _timedOut = true);
      }
    });
  }

  void _handleAnswer(int index) {
    if (_selectedAnswer != null || _timedOut) return;

    _timer?.cancel();
    setState(() {
      _selectedAnswer = index;
      _showResult = true;
      if (index == _questions[_currentIndex].correctAnswer) {
        _correctAnswers++;
      }
    });
    // No auto-advance: user taps "Далее"
  }

  void _handleNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _startTimer();
      });
    } else {
      setState(() => _quizCompleted = true);
    }
  }

  void _handleExit() {
    _timer?.cancel();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timedOut) return _buildTimedOutScreen();
    if (_quizCompleted) return _buildCompletedScreen();

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _handleExit,
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 5 ? Colors.red.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('${_timeLeft}с',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Вопрос ${_currentIndex + 1} из ${_questions.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('$_correctAnswers правильных',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Question Card (Expanded, scrollable only for answers) ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text — compact
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.brain, color: Color(0xFF7C3AED), size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Answer options
                        Expanded(
                          child: ListView.builder(
                            itemCount: question.options.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedAnswer == index;
                              final isCorrect = index == question.correctAnswer;
                              final showCorrect = _showResult && isCorrect;
                              final showWrong = _showResult && isSelected && !isCorrect;

                              Color borderColor = Colors.grey.shade200;
                              Color bgColor = Colors.grey.shade50;
                              Widget? suffix;

                              if (showCorrect) {
                                borderColor = Colors.green;
                                bgColor = Colors.green.shade50;
                                suffix = const Icon(LucideIcons.check, color: Colors.green, size: 18);
                              } else if (showWrong) {
                                borderColor = Colors.red;
                                bgColor = Colors.red.shade50;
                                suffix = const Icon(LucideIcons.x, color: Colors.red, size: 18);
                              } else if (isSelected) {
                                borderColor = const Color(0xFF7C3AED);
                                bgColor = const Color(0xFF7C3AED).withOpacity(0.1);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => _handleAnswer(index),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      border: Border.all(color: borderColor, width: 2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            question.options[index],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: showCorrect
                                                  ? Colors.green.shade900
                                                  : showWrong
                                                      ? Colors.red.shade900
                                                      : AppColors.textMain,
                                              fontWeight: (showCorrect || showWrong || isSelected)
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (suffix != null) suffix,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Explanation panel — always fully visible outside card ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showResult
                    ? Padding(
                        key: const ValueKey('explanation'),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedAnswer == question.correctAnswer
                                ? Colors.green.shade600
                                : const Color(0xFF1D4ED8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _selectedAnswer == question.correctAnswer
                                    ? LucideIcons.checkCircle
                                    : LucideIcons.info,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  question.explanation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('no-explanation')),
              ),

              // ── Bottom row: reward + next button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    // Reward chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text('Награда', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(
                            '+${_questions.length * 5}м',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Далее button (visible only after answer)
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _showResult ? 1.0 : 0.35,
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _showResult ? _handleNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7C3AED),
                            disabledBackgroundColor: Colors.white.withOpacity(0.3),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentIndex < _questions.length - 1 ? 'Далее →' : 'Завершить',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimedOutScreen() {
    final earnedMinutes = _correctAnswers * 5;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFFEA580C), Color(0xFFD97706)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.alarm, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        'Время вышло!',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'К сожалению, вы не успели ответить на вопрос ${_currentIndex + 1} из ${_questions.length}. Попытка завершена.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.alertTriangle, color: Color(0xFFEA580C)),
                                SizedBox(width: 8),
                                Text('Результат попытки', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$_correctAnswers из ${_currentIndex} правильных',
                              style: const TextStyle(fontSize: 20),
                            ),
                            if (earnedMinutes > 0) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(LucideIcons.award, color: Colors.green, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      '+$earnedMinutes минут',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text('заработано до окончания времени', 
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ] else ...[
                               const SizedBox(height: 12),
                               const Text('Дополнительное время не заработано', 
                                 style: TextStyle(color: Color(0xFFEA580C), fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleExit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Вернуться на главную'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedScreen() {
    final earnedMinutes = _correctAnswers * 5;
    final isPerfect = _correctAnswers == _questions.length;
    final iconData = isPerfect ? Icons.emoji_events : (_correctAnswers >= 3 ? Icons.celebration : Icons.fitness_center);
    final title = isPerfect ? 'Идеально!' : (_correctAnswers >= 3 ? 'Отлично!' : 'Хорошая попытка!');

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Icon(iconData, size: 64, color: Colors.amberAccent),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Вы ответили правильно на $_correctAnswers из ${_questions.length} вопросов',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade50, const Color(0xFFECFDF5)], // Emerald 50 hex
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.award, color: Colors.green, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              '+$earnedMinutes минут',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                            const Text(
                              'Дополнительное время заработано!',
                              style: TextStyle(color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleExit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Продолжить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
