import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_failure.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository_factory.dart';

enum _RecoveryStep {
  requestCode,
  confirmCode,
}

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isBootstrapping = true;
  _RecoveryStep _step = _RecoveryStep.requestCode;
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
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final repository = await AuthRepositoryFactory.create();
      final savedEmail = await repository.readLastEmail();

      if (!mounted) {
        return;
      }

      setState(() {
        _repository = repository;
        if (_emailController.text.trim().isEmpty &&
            savedEmail != null &&
            savedEmail.trim().isNotEmpty) {
          _emailController.text = savedEmail.trim();
        }
      });
    } catch (_) {
      // The form can still be used even if the cache bootstrap fails.
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

  Future<void> _requestCode() async {
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

    try {
      final repository = await _getRepository();
      await repository.saveLastEmail(email);
      await repository.requestPasswordReset(email);

      if (!mounted) {
        return;
      }

      setState(() {
        _step = _RecoveryStep.confirmCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te enviamos un PIN de recuperacion a tu correo.'),
        ),
      );
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

  Future<void> _confirmReset() async {
    if (_isLoading) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nueva contrasena y la confirmacion deben coincidir.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    try {
      final repository = await _getRepository();
      await repository.saveLastEmail(email);
      await repository.confirmPasswordReset(
        email: email,
        code: _codeController.text.trim(),
        newPassword: newPassword,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contrasena restablecida correctamente. Inicia sesion otra vez.'),
        ),
      );

      Navigator.of(context).pop();
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

  void _backToRequestStep() {
    setState(() {
      _step = _RecoveryStep.requestCode;
      _codeController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brand),
        ),
      );
    }

    final theme = Theme.of(context);
    final isRequestStep = _step == _RecoveryStep.requestCode;
    final title = isRequestStep ? 'Recupera tu acceso' : 'Confirma tu recuperacion';
    final subtitle = isRequestStep
        ? 'Solicita un PIN por correo y luego define una contrasena nueva.'
        : 'Ingresa el PIN recibido y crea una contrasena segura para volver a entrar.';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 220,
                      child: Image.asset(
                        'assets/images/recover_password.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, _, __) {
                          return Container(
                            color: AppColors.activeSoft,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: AppColors.brand,
                              size: 38,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.warning,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Correo',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: isRequestStep ? TextInputAction.done : TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'cliente@safepet.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Ingresa el correo de tu cuenta';
                              }

                              if (!email.contains('@') || !email.contains('.')) {
                                return 'Ingresa un correo valido';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (!isRequestStep) ...[
                            TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'PIN de recuperacion',
                                prefixIcon: Icon(Icons.pin_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresa el PIN que recibiste';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Nueva contrasena',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (value) {
                                final password = value ?? '';
                                if (password.isEmpty) {
                                  return 'Ingresa la nueva contrasena';
                                }

                                if (password.length < 8) {
                                  return 'La contrasena debe tener al menos 8 caracteres';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _confirmReset(),
                              decoration: const InputDecoration(
                                labelText: 'Confirmar contrasena',
                                prefixIcon: Icon(Icons.lock_reset_outlined),
                              ),
                              validator: (value) {
                                final confirmation = value ?? '';
                                if (confirmation.isEmpty) {
                                  return 'Confirma la nueva contrasena';
                                }

                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : isRequestStep
                                      ? _requestCode
                                      : _confirmReset,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.2),
                                    )
                                  : Text(isRequestStep ? 'Enviar PIN' : 'Restablecer contrasena'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : isRequestStep
                                    ? () {
                                        Navigator.of(context).pop();
                                      }
                                    : _backToRequestStep,
                            child: Text(
                              isRequestStep ? 'Volver al Inicio de sesion' : 'Cambiar correo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
