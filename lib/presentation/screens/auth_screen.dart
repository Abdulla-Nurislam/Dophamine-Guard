import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/app_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum AuthView { login, register, forgotPassword }

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String cleaned = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleaned.isNotEmpty) {
      if (cleaned.startsWith('8')) {
        cleaned = '7${cleaned.substring(1)}';
      } else if (!cleaned.startsWith('7')) {
        cleaned = '7$cleaned';
      }
    }
    if (cleaned.length > 11) {
      cleaned = cleaned.substring(0, 11);
    }
    if (cleaned.isEmpty) return const TextEditingValue(text: '');
    
    String digits = cleaned.substring(1);
    String formatted = '+7';
    if (digits.isNotEmpty) formatted += ' (${digits.substring(0, digits.length > 3 ? 3 : digits.length)}';
    if (digits.length >= 4) {
      formatted += ') ${digits.substring(3, digits.length > 6 ? 6 : digits.length)}';
    } else if (formatted.endsWith(' (')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    if (digits.length >= 7) {
      formatted += '-${digits.substring(6, digits.length > 8 ? 8 : digits.length)}';
    }
    if (digits.length >= 9) {
      formatted += '-${digits.substring(8, digits.length)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthView _view = AuthView.login;
  bool _showLoginPassword = false;
  bool _showRegPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _forgotEmailController = TextEditingController();
  bool _forgotEmailSent = false;

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (credential.user != null) {
        final email = credential.user!.email ?? '';
        AppState.userEmail.value = email;
        AppState.userName.value = credential.user!.displayName ?? email.split('@').first;
        
        if (mounted) {
          context.go('/goal-setup');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ошибка входа';
      if (e.code == 'user-not-found') {
        message = 'Пользователь не найден';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Неверный логин или пароль';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный email';
      } else if (e.code == 'internal-error') {
        message = 'Внутренняя ошибка. Убедитесь, что Authentication (Email/Password) включен в Firebase Console.';
      } else {
        message = e.message ?? 'Неизвестная ошибка: ${e.code}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_firstNameController.text.isEmpty || _regEmailController.text.isEmpty || _regPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните основные поля')),
      );
      return;
    }

    if (_regPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _regEmailController.text.trim(),
        password: _regPasswordController.text,
      );

      if (credential.user != null) {
        // Update display name
        final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
        final email = _regEmailController.text.trim();
        await credential.user!.updateDisplayName(fullName);

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'name': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'subscription': 'none',
          'streak': 0,
        }).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Firestore timeout: Database probably not created yet!');
          },
        );

        // Save user data globally
        AppState.userName.value = fullName;
        AppState.userEmail.value = _regEmailController.text.trim();

        if (mounted) {
          context.go('/goal-setup');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ошибка регистрации';
      if (e.code == 'weak-password') {
        message = 'Пароль должен содержать минимум 6 символов';
      } else if (e.code == 'email-already-in-use') {
        message = 'Этот email уже используется';
      } else if (e.code == 'invalid-email') {
        message = 'Некорректный email';
      } else if (e.code == 'internal-error') {
        message = 'Внутренняя ошибка. Убедитесь, что Authentication (Email/Password) включен в Firebase Console.';
      } else {
        message = e.message ?? 'Неизвестная ошибка: ${e.code}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFFEC4899),
              Color(0xFFF97316),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🛡️',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DophamineGuard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Ваш путь к цифровой свободе',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Auth Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // View Toggle
                      if (_view != AuthView.forgotPassword)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ToggleButton(
                                  text: 'Вход',
                                  isSelected: _view == AuthView.login,
                                  onTap: () => setState(() => _view = AuthView.login),
                                ),
                              ),
                              Expanded(
                                child: _ToggleButton(
                                  text: 'Регистрация',
                                  isSelected: _view == AuthView.register,
                                  onTap: () => setState(() => _view = AuthView.register),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_view != AuthView.forgotPassword)
                        const SizedBox(height: 24),

                      if (_view == AuthView.login)
                        _buildLoginForm()
                      else if (_view == AuthView.register)
                        _buildRegisterForm()
                      else
                        _buildForgotPasswordForm(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Продолжая, вы принимаете Условия использования',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        AppTextField(
          label: 'Электронная почта',
          hint: 'you@example.com',
          prefixIcon: LucideIcons.mail,
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Пароль',
          hint: '••••••••',
          prefixIcon: LucideIcons.lock,
          obscureText: !_showLoginPassword,
          controller: _loginPasswordController,
          suffixIcon: _showLoginPassword ? LucideIcons.eyeOff : LucideIcons.eye,
          onSuffixIconPressed: () => setState(() => _showLoginPassword = !_showLoginPassword),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _view = AuthView.forgotPassword),
            child: const Text(
              'Забыли пароль?',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.normal),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Войти',
          onPressed: _handleLogin,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Нет аккаунта? ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => setState(() => _view = AuthView.register),
              child: const Text(
                'Зарегистрироваться',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Имя',
                hint: 'Имя',
                prefixIcon: LucideIcons.user,
                controller: _firstNameController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Фамилия',
                hint: 'Фамилия',
                prefixIcon: LucideIcons.user,
                controller: _lastNameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Номер телефона',
          hint: '+7 (XXX) XXX-XX-XX',
          prefixIcon: LucideIcons.phone,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneInputFormatter()],
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Электронная почта',
          hint: 'example@gmail.com',
          prefixIcon: LucideIcons.mail,
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Пароль',
          hint: 'Минимум 8 символов',
          prefixIcon: LucideIcons.lock,
          obscureText: !_showRegPassword,
          controller: _regPasswordController,
          suffixIcon: _showRegPassword ? LucideIcons.eyeOff : LucideIcons.eye,
          onSuffixIconPressed: () => setState(() => _showRegPassword = !_showRegPassword),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Подтвердите пароль',
          hint: 'Повторите пароль',
          prefixIcon: LucideIcons.lock,
          obscureText: !_showConfirmPassword,
          controller: _confirmPasswordController,
          suffixIcon: _showConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
          onSuffixIconPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
          errorText: (_confirmPasswordController.text.isNotEmpty && 
                     _regPasswordController.text != _confirmPasswordController.text) 
                     ? 'Пароли не совпадают' : null,
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Создать аккаунт',
          onPressed: _handleRegister,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Уже есть аккаунт? ', style: TextStyle(color: AppColors.textSecondary)),
            GestureDetector(
              onTap: () => setState(() => _view = AuthView.login),
              child: const Text(
                'Войти',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    if (_forgotEmailSent) {
      return Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
            child: const Icon(LucideIcons.mail, color: Color(0xFF2563EB), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Проверьте почту', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 8),
          const Text('Мы отправили инструкции по восстановлению пароля', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          AppButton(text: 'Вернуться ко входу', onPressed: () => setState(() { _view = AuthView.login; _forgotEmailSent = false; })),
        ],
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _view = AuthView.login),
              child: const Icon(Icons.arrow_back, color: AppColors.textMain),
            ),
            const Text('Восстановление', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
            const SizedBox(width: 24),
          ],
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Электронная почта',
          hint: 'you@example.com',
          prefixIcon: LucideIcons.mail,
          controller: _forgotEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Сбросить пароль',
          isLoading: _isLoading,
          onPressed: () async {
            if (_forgotEmailController.text.isNotEmpty) {
              setState(() => _isLoading = true);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: _forgotEmailController.text.trim(),
                );
                setState(() => _forgotEmailSent = true);
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  String msg = e.message ?? 'Ошибка: ${e.code}';
                  if (e.code == 'internal-error') {
                     msg = 'Внутренняя ошибка. Проверьте настройки Firebase.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
