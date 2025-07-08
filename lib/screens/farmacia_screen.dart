import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../data/models/medicine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FarmaciaScreen());
  }
}

class FarmaciaScreen extends StatefulWidget {
  const FarmaciaScreen({super.key});

  @override
  State<FarmaciaScreen> createState() => _FarmaciaScreenState();
}

class _FarmaciaScreenState extends State<FarmaciaScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _textController = TextEditingController();
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _refreshMedicineList();
  }

  void _refreshMedicineList() {
    setState(() {
      _medicines = _dbHelper.getMedicines();
    });
  }

  void _addMedicine() async {
    if (_textController.text.isNotEmpty) {
      await _dbHelper.insertMedicine(Medicine(name: _textController.text));
      _textController.clear();
      _refreshMedicineList();
    }
  }

  void _deleteMedicine(int id) async {
    await _dbHelper.deleteMedicine(id);
    _refreshMedicineList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'New Medicine Name',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMedicine,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: _medicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No medicines found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final medicine = snapshot.data![index];
                      return ListTile(
                        title: Text(medicine.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteMedicine(medicine.id!),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
