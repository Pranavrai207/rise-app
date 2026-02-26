import 'package:flutter/material.dart';

import '../services/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.themeMode,
    required this.onToggleTheme,
    this.infoMessage,
  });

  final Future<void> Function(String email, String password) onLogin;
  final Future<void> Function(String email, String password) onRegister;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final String? infoMessage;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (_registerMode) {
        await widget.onRegister(email, password);
      } else {
        await widget.onLogin(email, password);
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Auth failed. Check credentials and backend status.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                tooltip: widget.themeMode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _registerMode ? 'Create account' : 'Welcome back',
                            style: AppTextStyles.h1(isDark),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Sign in to continue',
                            style: AppTextStyles.caption(isDark),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty || !v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password'),
                            validator: (value) {
                              if ((value ?? '').trim().length < 8) return 'Min 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (widget.infoMessage != null)
                            Text(
                              widget.infoMessage!,
                              style: const TextStyle(color: AppColors.info),
                            ),
                          if (widget.infoMessage != null) const SizedBox(height: AppSpacing.md),
                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          if (_error != null) const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed: _busy ? null : _submit,
                            child: Text(_busy ? 'Please wait...' : (_registerMode ? 'Create account' : 'Log in')),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () {
                                    setState(() {
                                      _registerMode = !_registerMode;
                                      _error = null;
                                    });
                                  },
                            child: Text(_registerMode ? 'Already have an account? Log in' : 'Need an account? Create one'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
