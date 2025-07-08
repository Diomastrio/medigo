import 'package:flutter/material.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CrearRecordatorioScreen extends StatefulWidget {
  @override
  _CrearRecordatorioScreenState createState() =>
      _CrearRecordatorioScreenState();
}

class _CrearRecordatorioScreenState extends State<CrearRecordatorioScreen> {
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 0);
  String selectedMedication = "Aspirina 100mg";
  int dosisCount = 2;
  String dosisType = "Tabletas";
  bool afterMeal1 = true;
  bool afterMeal2 = true;
  int duration = 14;
  String durationType = "Días";
  int selectedIconIndex = 0;
  int _currentNavIndex = 0;

  List<IconData> medicationIcons = [
    Icons.medication,
    Icons.local_pharmacy,
    Icons.health_and_safety,
    Icons.medical_services,
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    if (index == 0) {
      Navigator.of(context).pop(); // Go back to home
    } else if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil seleccionado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
            _buildDosisSection(),
            SizedBox(height: 24),

            // Cuando Section
            _buildWhenSection(),
            SizedBox(height: 24),

            // Duration Section
            _buildDurationSection(),
            SizedBox(height: 24),

            // Icon Selection
            _buildIconSection(),
            SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            selectedMedication,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildDosisSection() {
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
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dosisCount.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dosisType,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuando',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: afterMeal1,
                    onChanged: (bool? value) {
                      setState(() {
                        afterMeal1 = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      'Después de la comida',
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: afterMeal2,
                    onChanged: (bool? value) {
                      setState(() {
                        afterMeal2 = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      'Después de la comida',
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
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
                child: Text(
                  duration.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      durationType,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar icono',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIconIndex = index;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selectedIconIndex == index
                      ? Colors.blue[200]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  medicationIcons[index],
                  size: 30,
                  color: selectedIconIndex == index
                      ? Colors.blue[700]
                      : Colors.grey[600],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Handle save functionality
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Recordatorio guardado')));
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
