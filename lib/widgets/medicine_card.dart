import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/medicine.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({Key? key}) : super(key: key);

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() async {
    try {
      final medicines = await _dbHelper.getMedicines();
      if (mounted) {
        setState(() {
          _medicines = medicines;
        });
      }
    } catch (e) {
      print('Error loading medicines: $e');
    }
  }

  Widget _buildSingleMedicineCard(Medicine medicine) {
    // Default icon based on medicine name or use a generic one
    IconData icon = Icons.medication;
    Color iconColor = Colors.blue;

    // You can add logic here to assign different icons based on medicine name
    if (medicine.name.toLowerCase().contains('aspirin')) {
      icon = Icons.medication;
      iconColor = Colors.red;
    } else if (medicine.name.toLowerCase().contains('ibuprofeno')) {
      icon = Icons.circle;
      iconColor = Colors.orange;
    } else if (medicine.name.toLowerCase().contains('paracetamol')) {
      icon = Icons.local_hospital;
      iconColor = Colors.green;
    }

    return Container(
      padding: EdgeInsets.all(16),
      constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: iconColor, size: 25),
          ),
          SizedBox(height: 10),
          Text(
            medicine.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_medicines.isEmpty) {
      return Center(
        child: Text(
          'No hay medicamentos disponibles',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _medicines.map((medicine) {
          return Padding(
            padding: EdgeInsets.only(right: 15),
            child: _buildSingleMedicineCard(medicine),
          );
        }).toList(),
      ),
    );
  }
}
