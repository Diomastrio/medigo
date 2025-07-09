import 'package:flutter/material.dart';

class DurationSectionWidget extends StatelessWidget {
  final int duration;
  final String durationType;
  final Function(int) onDurationChanged;
  final Function(String) onDurationTypeChanged;

  const DurationSectionWidget({
    Key? key,
    required this.duration,
    required this.durationType,
    required this.onDurationChanged,
    required this.onDurationTypeChanged,
  }) : super(key: key);

  final List<String> durationTypes = const [
    "Días",
    "Semanas",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  initialValue: duration.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  onChanged: (value) {
                    final newDuration = int.tryParse(value) ?? duration;
                    onDurationChanged(newDuration);
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: durationType,
                  isExpanded: true,
                  underline: Container(),
                  items: durationTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onDurationTypeChanged(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}