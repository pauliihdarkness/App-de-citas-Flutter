import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../../data/models/user_model.dart';

class EditWorkEducationModal extends StatefulWidget {
  final UserJob initialJob;

  const EditWorkEducationModal({super.key, required this.initialJob});

  @override
  State<EditWorkEducationModal> createState() => _EditWorkEducationModalState();
}

class _EditWorkEducationModalState extends State<EditWorkEducationModal> {
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _educationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialJob.title);
    _companyController = TextEditingController(text: widget.initialJob.company);
    _educationController = TextEditingController(
      text: widget.initialJob.education,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updatedJob = UserJob(
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      education: _educationController.text.trim(),
    );
    context.pop(updatedJob);
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trabajo y Educación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Puesto',
              hint: 'Ej: Diseñador UX',
              icon: LucideIcons.briefcase,
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Empresa',
              hint: 'Ej: Google',
              icon: LucideIcons.building,
              controller: _companyController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Educación',
              hint: 'Ej: Universidad de Buenos Aires',
              icon: LucideIcons.graduationCap,
              controller: _educationController,
            ),
            const SizedBox(height: 32),
            GradientButton(text: 'Guardar', onPressed: _handleSave),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
