import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../data/models/dose_history.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<DoseHistory>> _doseHistoryFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadDoseHistory();
  }

  void _loadDoseHistory() {
    setState(() {
      _doseHistoryFuture = _dbHelper.getDoseHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Dosis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<DoseHistory>>(
        future: _doseHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay historial de dosis.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final historyList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadDoseHistory();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final history = historyList[index];
                final takenAtDate = DateTime.parse(history.takenAt);
                final formattedDate = DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(takenAtDate);

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(Icons.check, color: Colors.green.shade700),
                    ),
                    title: Text(
                      history.medicineName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${history.doseDetails}\nTomado: $formattedDate',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
