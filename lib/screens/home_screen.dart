import '../main.dart'; // Import the main.dart file for AuthScreen
import 'package:flutter/material.dart';
import 'menu_screen.dart'; // Import the new menu screen
import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar
import '../widgets/medicine_card.dart'; // Import the new medicine card widget
import '../data/database_helper.dart';
import '../data/models/reminder.dart';
import 'confirmation_screen.dart'; // Import the new confirmation screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isMenuOpen = false;
  int _currentNavIndex = 0;
  List<Reminder> _reminders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0, // Change to 1.0 for full menu animation
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadReminders();
  }

  void _loadReminders() async {
    var reminders = await _dbHelper.getReminders();
    // A simple way to trigger a rebuild when returning to the screen
    // after adding a new reminder.
    if (mounted) {
      setState(() {
        _reminders = reminders;
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    // Handle navigation logic here
    if (index == 2) {
      // Navigate to profile or other screen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil seleccionado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Main content (stays in place)
          GestureDetector(
            onTap: _isMenuOpen ? _toggleMenu : null,
            child: _buildMainContent(),
          ),

          // Menu overlay
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                left:
                    -MediaQuery.of(context).size.width *
                    0.7 *
                    (1 - _slideAnimation.value),
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.7,
                child: MenuScreen(onMenuClose: _toggleMenu),
              );
            },
          ),

          // Dark overlay when menu is open
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: _toggleMenu,
        ),
        title: Text(
          'MediGO',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Notifications icon
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.orange),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Alertas seleccionado')));
            },
          ),
          // Favorites/Reminders icon
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notificación seleccionado')),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Buscar medicamentos, recordatorios...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),

            // Próximas dosis Section
            _buildSectionHeader('Próximas dosis', 'Ver todo'),
            SizedBox(height: 15),
            _reminders.isEmpty
                ? Center(child: Text('No hay recordatorios.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      return _buildDoseCard(reminder, 'Confirmar', Colors.blue);
                    },
                  ),
            SizedBox(height: 25),

            // Medicamentos Actuales Section
            _buildSectionHeader('Medicamentos Actuales', 'Ver todo'),
            SizedBox(height: 15),
            // Replace the old Row with the new MedicineCard widget
            MedicineCard(),
            SizedBox(height: 25),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          actionText,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDoseCard(Reminder reminder, String action, Color actionColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock, color: Colors.white, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              reminder.medicineName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmationScreen(reminder: reminder),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(action, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
