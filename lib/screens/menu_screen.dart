import 'package:flutter/material.dart';
import 'recordatorio_screen.dart'; // Add this import

class MenuScreen extends StatelessWidget {
  final VoidCallback onMenuClose;

  const MenuScreen({Key? key, required this.onMenuClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administra tus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Dosis y Medicamentos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Menu Items List
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _buildMenuList(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.access_time, 'label': 'Historial', 'color': Colors.red},
      {'icon': Icons.favorite, 'label': 'Recordatorios', 'color': Colors.pink},
      {'icon': Icons.local_pharmacy, 'label': 'Farmacia', 'color': Colors.blue},
      {
        'icon': Icons.monitor_heart,
        'label': 'Medicamento',
        'color': Colors.purple,
      },
    ];

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icon'], color: item['color'], size: 24),
            ),
            title: Text(
              item['label'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
            onTap: () {
              // Handle menu item tap
              onMenuClose();
              
              // Navigate to specific screens based on the selected item
              if (item['label'] == 'Recordatorios') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CrearRecordatorioScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['label']} seleccionado')),
                );
              }
            },
          ),
        );
      },
    );
  }
}
