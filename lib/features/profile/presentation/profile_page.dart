import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_models.dart';
import 'package:petsafe_movil_app/features/profile/data/profile_api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileApiService _apiService;

  AuthUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();

    final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
    _apiService = ProfileApiService(
      apiClient: ApiClient(),
      sessionStorage: sessionStorage,
    );

    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _apiService.getMe();
      if (!mounted) return;
      setState(() {
        _user = user;
        _nameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _phoneController.text = user.phone ?? '';
        _isLoading = false;
      });
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ApiFailure.fromDioException(e).message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo cargar el perfil.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final firstName = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y apellido son requeridos.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _apiService.updateMe(
        firstName: firstName,
        lastName: lastName,
        phone: phone.isEmpty ? null : phone,
      );
      if (!mounted) return;
      final current = _user!;
      setState(() {
        _user = AuthUser(
          id: current.id,
          email: current.email,
          roles: current.roles,
          firstName: firstName,
          lastName: lastName,
          phone: phone.isEmpty ? null : phone,
          isVet: current.isVet,
          requiresPasswordChange: current.requiresPasswordChange,
        );
        _nameController.text = firstName;
        _lastNameController.text = lastName;
        _phoneController.text = phone;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente.')),
      );
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiFailure.fromDioException(e).message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el perfil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return const FeaturePageScaffold(
        title: 'Perfil',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _user == null) {
      return FeaturePageScaffold(
        title: 'Perfil',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _loadUser,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FeaturePageScaffold(
      title: 'Perfil',
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + bottomInset),
        children: [
          _profileCard(context),
          const SizedBox(height: 20),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Datos personales', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _field(label: 'Nombre', controller: _nameController),
          const SizedBox(height: 12),
          _field(label: 'Apellido', controller: _lastNameController),
          const SizedBox(height: 12),
          _field(
            label: 'Teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          if (_user != null) ...[
            const SizedBox(height: 20),
            Text('Informacion de cuenta', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _readonlyField('Correo', _user!.email),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = _nameController.text;
    final lastName = _lastNameController.text;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserInitialsAvatar(
            fullName: '$firstName $lastName'.trim(),
            size: 80,
            showShadow: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName'.trim().isEmpty
                      ? (_user?.email ?? '')
                      : '$firstName $lastName'.trim(),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (_user != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _user!.email,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: !_isSaving,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
