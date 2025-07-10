import 'package:flutter/material.dart';
import 'package:medigo/data/models/reminder.dart';

class MediGoSuccessModal extends StatelessWidget {
  final Reminder reminder;
  const MediGoSuccessModal({Key? key, required this.reminder})
    : super(key: key);

  static void show(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MediGoSuccessModal(reminder: reminder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MediGO Title
            const Text(
              'MediGO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 40),

            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 4),
              ),
              child: const Icon(Icons.check, color: Colors.blue, size: 50),
            ),

            const SizedBox(height: 40),

            // Success Message
            const Text(
              '¡Éxito!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Has tomado tu medicamento\ncorrectamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black, height: 1.4),
            ),

            const SizedBox(height: 40),

            // Medication Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Medicamento:', reminder.medicineName),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Dosis:',
                    '${reminder.doseCount} ${reminder.doseType} (${reminder.doseUnit})',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Hora:', reminder.time),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Ver Historial Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Handle navigation to history screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ver Historial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }
}
