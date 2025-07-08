import 'package:flutter/material.dart';
import 'package:medigo/screens/recordatorio_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({Key? key, this.currentIndex = 0, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => onTap?.call(0),
            child: Icon(
              Icons.home,
              size: 28,
              color: currentIndex == 0 ? Colors.blue : Colors.grey[600],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearRecordatorioScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add, size: 32, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => onTap?.call(2),
            child: Icon(
              Icons.person,
              size: 28,
              color: currentIndex == 2 ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
