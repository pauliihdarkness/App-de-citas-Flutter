import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';

class EditBioModal extends StatefulWidget {
  final String initialBio;

  const EditBioModal({super.key, required this.initialBio});

  @override
  State<EditBioModal> createState() => _EditBioModalState();
}

class _EditBioModalState extends State<EditBioModal> {
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    context.pop(_bioController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Editar Bio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomInput(
            label: 'Sobre mí',
            hint: 'Escribe algo sobre ti...',
            icon: LucideIcons.alignLeft,
            controller: _bioController,
            maxLines: 6,
          ),
          const SizedBox(height: 32),
          GradientButton(text: 'Guardar', onPressed: _handleSave),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
