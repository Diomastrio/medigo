import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final VoidCallback onMenuClose;

  const MenuScreen({Key? key, required this.onMenuClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Icon(Icons.person, color: Colors.red, size: 30),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Usuario',
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

            // Menu Items Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildMenuGrid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.access_time, 'label': 'Diarias', 'color': Colors.red},
      {'icon': Icons.notifications, 'label': 'Alertas', 'color': Colors.orange},
      {'icon': Icons.favorite, 'label': 'Recordatorios', 'color': Colors.pink},
      {'icon': Icons.check, 'label': 'Notificación', 'color': Colors.green},
      {'icon': Icons.person, 'label': 'Farmacia', 'color': Colors.blue},
      {
        'icon': Icons.monitor_heart,
        'label': 'Medicamento',
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () {
            // Handle menu item tap
            onMenuClose();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item['label']} seleccionado')),
            );
          },
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 25),
                ),
                SizedBox(height: 10),
                Text(
                  item['label'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
