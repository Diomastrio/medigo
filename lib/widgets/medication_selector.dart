import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/medicine.dart';

class MedicationSelector extends StatefulWidget {
  final String selectedMedication;
  final ValueChanged<String> onMedicationChanged;

  const MedicationSelector({
    Key? key,
    required this.selectedMedication,
    required this.onMedicationChanged,
  }) : super(key: key);

  @override
  _MedicationSelectorState createState() => _MedicationSelectorState();
}

class _MedicationSelectorState extends State<MedicationSelector> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medicine> _medicines = [];
  bool _isLoadingMedicines = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await _dbHelper.getMedicines();
      setState(() {
        _medicines = medicines;
        _isLoadingMedicines = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicines = false;
      });
      print('Error loading medicines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicamento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isLoadingMedicines
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Cargando medicamentos...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : _medicines.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay medicamentos disponibles',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : DropdownButton<String>(
                  value: widget.selectedMedication,
                  isExpanded: true,
                  underline: Container(),
                  items: _medicines.map((Medicine medicine) {
                    return DropdownMenuItem<String>(
                      value: medicine.name,
                      child: Text(
                        medicine.name,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      widget.onMedicationChanged(newValue);
                    }
                  },
                ),
        ),
      ],
    );
  }
}
