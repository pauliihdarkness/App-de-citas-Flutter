import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/gradient_button.dart';

class EditSearchIntentModal extends StatefulWidget {
  final String initialIntent;

  const EditSearchIntentModal({super.key, required this.initialIntent});

  @override
  State<EditSearchIntentModal> createState() => _EditSearchIntentModalState();
}

class _EditSearchIntentModalState extends State<EditSearchIntentModal> {
  late String _selectedIntent;

  final List<String> _options = [
    'Relación seria',
    'Algo casual',
    'Amistad',
    'No lo sé aún',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIntent = widget.initialIntent;
    if (!_options.contains(_selectedIntent)) {
      _selectedIntent = _options.last;
    }
  }

  void _handleSave() {
    context.pop(_selectedIntent);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                '¿Qué estás buscando?',
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
          ..._options.map((option) => _buildOption(option)),
          const SizedBox(height: 32),
          GradientButton(text: 'Guardar', onPressed: _handleSave),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedIntent == option;
    return InkWell(
      onTap: () => setState(() => _selectedIntent = option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
