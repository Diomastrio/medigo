import 'package:flutter/material.dart';

class DosisSectionWidget extends StatelessWidget {
  final int dosisCount;
  final String dosisUnit;
  final String dosisType;
  final List<String> dosisUnits;
  final List<String> dosisTypes;
  final Function(int) onDosisCountChanged;
  final Function(String) onDosisUnitChanged;
  final Function(String) onDosisTypeChanged;

  const DosisSectionWidget({
    Key? key,
    required this.dosisCount,
    required this.dosisUnit,
    required this.dosisType,
    required this.dosisUnits,
    required this.dosisTypes,
    required this.onDosisCountChanged,
    required this.onDosisUnitChanged,
    required this.onDosisTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            // Dose amount input
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  initialValue: dosisCount.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  onChanged: (value) {
                    final newCount = int.tryParse(value) ?? dosisCount;
                    onDosisCountChanged(newCount);
                  },
                ),
              ),
            ),
            SizedBox(width: 8),
            // Unit dropdown
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dosisUnit,
                    isExpanded: true,
                    items: dosisUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onDosisUnitChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Medication form dropdown
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dosisType,
                    isExpanded: true,
                    items: dosisTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onDosisTypeChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
