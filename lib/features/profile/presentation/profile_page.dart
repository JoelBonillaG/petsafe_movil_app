import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingName = false;
  bool _isEditingLastName = false;
  bool _isEditingPhone = false;
  
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Joel');
    _lastNameController = TextEditingController(text: 'Bonilla');
    _phoneController = TextEditingController(text: '+593 9XX XXX XXX');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return FeaturePageScaffold(
      title: 'Perfil',
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + bottomInset),
        children: [
          _profileCard(context),
          const SizedBox(height: 20),
          Text('Datos personales', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _editableField(
            label: 'Nombre',
            controller: _nameController,
            isEditing: _isEditingName,
            onEdit: () => setState(() => _isEditingName = true),
            onSave: () => setState(() => _isEditingName = false),
          ),
          const SizedBox(height: 12),
          _editableField(
            label: 'Apellido',
            controller: _lastNameController,
            isEditing: _isEditingLastName,
            onEdit: () => setState(() => _isEditingLastName = true),
            onSave: () => setState(() => _isEditingLastName = false),
          ),
          const SizedBox(height: 12),
          _editableField(
            label: 'Teléfono',
            controller: _phoneController,
            isEditing: _isEditingPhone,
            onEdit: () => setState(() => _isEditingPhone = true),
            onSave: () => setState(() => _isEditingPhone = false),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Guardar cambios'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      '$firstName $lastName',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.activeSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Perfil activo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
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
                if (isEditing)
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      autofocus: true,
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.success),
              onPressed: onSave,
              iconSize: 20,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.brand),
              onPressed: onEdit,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEditingName = false;
      _isEditingLastName = false;
      _isEditingPhone = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados en el mockup.')),
    );
  }
}
