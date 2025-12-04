import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/gradient_button.dart';
import '../../../data/models/user_model.dart';

class EditLifestyleModal extends StatefulWidget {
  final UserLifestyle initialLifestyle;

  const EditLifestyleModal({super.key, required this.initialLifestyle});

  @override
  State<EditLifestyleModal> createState() => _EditLifestyleModalState();
}

class _EditLifestyleModalState extends State<EditLifestyleModal> {
  late String _drink;
  late String _smoke;
  late String _workout;
  late String _zodiac;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _drink = widget.initialLifestyle.drink;
    _smoke = widget.initialLifestyle.smoke;
    _workout = widget.initialLifestyle.workout;
    _zodiac = widget.initialLifestyle.zodiac;
    _heightController = TextEditingController(
      text: widget.initialLifestyle.height,
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final updatedLifestyle = UserLifestyle(
      drink: _drink,
      smoke: _smoke,
      workout: _workout,
      zodiac: _zodiac,
      height: _heightController.text.trim(),
    );
    context.pop(updatedLifestyle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estilo de Vida',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdown(
                    label: 'Bebida',
                    value: _drink,
                    items: [
                      'Frecuentemente',
                      'Socialmente',
                      'Nunca',
                      'Prefiero no decir',
                    ],
                    onChanged: (val) => setState(() => _drink = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Tabaco',
                    value: _smoke,
                    items: [
                      'Fumador',
                      'No fumador',
                      'Ocasionalmente',
                      'Prefiero no decir',
                    ],
                    onChanged: (val) => setState(() => _smoke = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Ejercicio',
                    value: _workout,
                    items: ['Diario', 'A veces', 'Nunca', 'Prefiero no decir'],
                    onChanged: (val) => setState(() => _workout = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Signo Zodiacal',
                    value: _zodiac,
                    items: [
                      'Aries',
                      'Tauro',
                      'Géminis',
                      'Cáncer',
                      'Leo',
                      'Virgo',
                      'Libra',
                      'Escorpio',
                      'Sagitario',
                      'Capricornio',
                      'Acuario',
                      'Piscis',
                    ],
                    onChanged: (val) => setState(() => _zodiac = val!),
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: 'Altura (cm)',
                    hint: 'Ej: 175',
                    icon: LucideIcons.ruler,
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(text: 'Guardar', onPressed: _handleSave),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Ensure value is in items
    if (!items.contains(value)) {
      if (!items.contains('Prefiero no decir')) {
        items = [...items, 'Prefiero no decir'];
      }
      if (!items.contains(value)) {
        value = items.first;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              icon: const Icon(
                LucideIcons.chevronDown,
                color: AppColors.textSecondary,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
