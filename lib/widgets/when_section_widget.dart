import 'package:flutter/material.dart';

enum MedicationTiming { emptyStomach, afterMeal }

class WhenSectionWidget extends StatelessWidget {
  final MedicationTiming? selectedTiming;
  final Function(MedicationTiming?) onTimingChanged;

  const WhenSectionWidget({
    Key? key,
    required this.selectedTiming,
    required this.onTimingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuándo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildTimingOption(
                timing: MedicationTiming.emptyStomach,
                title: 'Estómago vacío',
                subtitle: 'Tomar sin comida',
                icon: Icons.schedule,
              ),
              SizedBox(height: 8),
              _buildTimingOption(
                timing: MedicationTiming.afterMeal,
                title: 'Después de comer',
                subtitle: 'Tomar con o después de comida',
                icon: Icons.restaurant,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingOption({
    required MedicationTiming timing,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedTiming == timing;

    return GestureDetector(
      onTap: () => onTimingChanged(timing),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Radio<MedicationTiming>(
              value: timing,
              groupValue: selectedTiming,
              onChanged: onTimingChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
