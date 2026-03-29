import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_failure.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository_factory.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberSession = true;
  bool _isLoading = false;
  bool _isBootstrapping = true;
  bool _isPasswordVisible = false;
  AuthRepository? _repository;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty) {
      _emailController.text = widget.initialEmail!.trim();
    }
    _bootstrap();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final repository = await AuthRepositoryFactory.create();
      final remembered = await repository.isSessionRemembered();
      final savedEmail = await repository.readLastEmail();

      if (!mounted) {
        return;
      }

      setState(() {
        _repository = repository;
        _rememberSession = remembered;
        if (_emailController.text.trim().isEmpty &&
            savedEmail != null &&
            savedEmail.trim().isNotEmpty) {
          _emailController.text = savedEmail.trim();
        }
      });

      if (remembered) {
        final restoredSession = await repository.restoreRememberedSession();
        if (!mounted) {
          return;
        }

        if (restoredSession != null) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
          return;
        }

        final updatedRemembered = await repository.isSessionRemembered();
        if (!mounted) {
          return;
        }

        setState(() {
          _rememberSession = updatedRemembered;
        });
      }
    } catch (_) {
      // The form remains usable even if bootstrap fails.
    }

    if (mounted) {
      setState(() {
        _isBootstrapping = false;
      });
    }
  }

  Future<AuthRepository> _getRepository() async {
    final repository = _repository;
    if (repository != null) {
      return repository;
    }

    final createdRepository = await AuthRepositoryFactory.create();
    _repository = createdRepository;
    return createdRepository;
  }

  Future<void> _enterApp() async {
    if (_isLoading) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final repository = await _getRepository();
      await repository.saveLastEmail(email);

      final session = await repository.login(
        email: email,
        password: password,
        rememberSession: _rememberSession,
      );

      if (!mounted) {
        return;
      }

      _passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            session.user.requiresPasswordChange
                ? 'Tu cuenta requiere cambio de contrasena.'
                : 'Sesion iniciada correctamente.',
          ),
        ),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openRecovery() {
    Navigator.of(context).pushNamed(
      AppRoutes.recovery,
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: AppColors.brand),
                SizedBox(height: 16),
                Text('Preparando PetSafe...'),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.activeSoft,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            color: AppColors.brand,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'PetSafe',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accede a tus mascotas, citas e historial clinico desde un solo lugar.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Ingresa tu correo';
                            }

                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Ingresa un correo valido';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _enterApp(),
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) {
                              return 'Ingresa tu contrasena';
                            }

                            if (password.length < 8) {
                              return 'La contrasena debe tener al menos 8 caracteres';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberSession,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberSession = value ?? false;
                                      });
                                    },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Recordar sesion',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _enterApp,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                )
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isLoading ? null : _openRecovery,
                          child: const Text('Recuperar contrasena'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
