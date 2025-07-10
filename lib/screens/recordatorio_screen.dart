import 'package:flutter/material.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/dosis_section_widget.dart';
import '../widgets/when_section_widget.dart';
import '../widgets/duration_section_widget.dart';
import '../data/database_helper.dart';
import '../data/models/medicine.dart';
import '../data/models/reminder.dart';
import '../services/notification_service.dart'; // Add this import

class CrearRecordatorioScreen extends StatefulWidget {
  @override
  _CrearRecordatorioScreenState createState() =>
      _CrearRecordatorioScreenState();
}

class _CrearRecordatorioScreenState extends State<CrearRecordatorioScreen> {
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 0);
  String selectedMedication = "Aspirina 100mg";
  int dosisCount = 2;
  String dosisUnit = "mg";
  String dosisType = "Tableta";
  MedicationTiming? selectedTiming = MedicationTiming.emptyStomach;
  int duration = 14;
  String durationType = "Días";
  int selectedIconIndex = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medicine> _medicines = [];
  bool _isLoadingMedicines = true;

  final List<String> dosisUnits = [
    "mg",
    "ml",
    "unidades",
    "inhalaciones",
    "parche",
  ];
  final List<String> dosisTypes = [
    "Tableta",
    "Cápsula",
    "Líquido",
    "Inhalador",
    "Parche transdérmico",
  ];

  // Mapping of medication forms to their suggested units
  final Map<String, String> _dosisTypeToUnitMap = {
    "Tableta": "mg",
    "Cápsula": "mg",
    "Líquido": "ml",
    "Inhalador": "inhalaciones",
    "Parche transdérmico": "parche",
  };

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
        if (_medicines.isNotEmpty) {
          selectedMedication = _medicines.first.name;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicines = false;
      });
      print('Error loading medicines: $e');
    }
  }

  void _onDosisTypeChanged(String newType) {
    setState(() {
      dosisType = newType;
      // Automatically suggest the appropriate unit based on the medication form
      if (_dosisTypeToUnitMap.containsKey(newType)) {
        dosisUnit = _dosisTypeToUnitMap[newType]!;
      }
    });
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil seleccionado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Nuevo Recordatorio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker
            _buildTimePickerSection(),
            SizedBox(height: 24),

            // Medication Selection
            _buildMedicationSection(),
            SizedBox(height: 24),

            // Dosis Section
            DosisSectionWidget(
              dosisCount: dosisCount,
              dosisUnit: dosisUnit,
              dosisType: dosisType,
              dosisUnits: dosisUnits,
              dosisTypes: dosisTypes,
              onDosisCountChanged: (newCount) {
                setState(() {
                  dosisCount = newCount;
                });
              },
              onDosisUnitChanged: (newUnit) {
                setState(() {
                  dosisUnit = newUnit;
                });
              },
              onDosisTypeChanged: _onDosisTypeChanged,
            ),
            SizedBox(height: 24),

            // When Section
            WhenSectionWidget(
              selectedTiming: selectedTiming,
              onTimingChanged: (MedicationTiming? newTiming) {
                setState(() {
                  selectedTiming = newTiming;
                });
              },
            ),
            SizedBox(height: 24),

            // Duration Section
            DurationSectionWidget(
              duration: duration,
              durationType: durationType,
              onDurationChanged: (newDuration) {
                setState(() {
                  duration = newDuration;
                });
              },
              onDurationTypeChanged: (newType) {
                setState(() {
                  durationType = newType;
                });
              },
            ),
            SizedBox(height: 24),

            // Save Button
            _buildSaveButton(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: -1, // No item is selected
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildTimePickerSection() {
    return CustomTimePicker(
      initialTime: selectedTime,
      onTimeChanged: (TimeOfDay newTime) {
        setState(() {
          selectedTime = newTime;
        });
      },
    );
  }

  Widget _buildMedicationSection() {
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
                  value: selectedMedication,
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
                      setState(() {
                        selectedMedication = newValue;
                      });
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          final newReminder = Reminder(
            medicineName: selectedMedication,
            time:
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
            doseCount: dosisCount,
            doseUnit: dosisUnit,
            doseType: dosisType,
            timing: selectedTiming?.toString().split('.').last,
            duration: duration,
            durationType: durationType,
          );

          await _dbHelper.insertReminder(newReminder);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Recordatorio guardado y notificación programada',
                ),
              ),
            );
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          'Guardar recordatorio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Para usar en tu app principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crear Recordatorio',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: CrearRecordatorioScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
