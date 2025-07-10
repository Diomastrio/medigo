import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medigo/screens/home_screen.dart';
import '../data/database_helper.dart';
import '../data/models/dose_history.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<DoseHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = DatabaseHelper().getDoseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tomas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<DoseHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay historial de tomas.'));
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              final takenAt = DateTime.parse(history.takenAt);
              final formattedDate = DateFormat.yMMMd().format(takenAt);
              final formattedTime = DateFormat.jm().format(takenAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    history.medicineName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(history.doseDetails),
                  trailing: Text(
                    '$formattedDate\n$formattedTime',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: -1, // No item is selected on the history screen
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home Screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          }
          // The profile is part of the home screen, so we can navigate there too.
          // For now, we'll just handle the home button.
        },
      ),
    );
  }
}
