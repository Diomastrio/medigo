import '../main.dart'; // Import the main.dart file for AuthScreen
import 'package:flutter/material.dart';
import 'menu_screen.dart'; // Import the new menu screen
import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar
import '../widgets/medicine_card.dart'; // Import the new medicine card widget
import '../widgets/mqtt_sync_button.dart'; // Import the MQTT sync button
import '../data/database_helper.dart';
import '../data/models/reminder.dart';
import '../data/models/medicine.dart';
import '../services/search_service.dart'; // Import the search service
import 'confirmation_screen.dart'; // Import the new confirmation screen
import 'recordatorio_screen.dart'; // Make sure this import exists
import 'package:medigo/screens/alerts_screen.dart';

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
  List<Reminder> _filteredReminders = [];
  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadMedicines();
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadReminders();
    _loadMedicines();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReminders();
    _loadMedicines();
  }

  // Convert existing load methods to async versions for better refresh handling
  Future<void> _loadRemindersAsync() async {
    try {
      var reminders = await _dbHelper.getReminders();
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _onSearchChanged();
        });
      }
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  Future<void> _loadMedicinesAsync() async {
    try {
      var medicines = await _dbHelper.getMedicines();
      if (mounted) {
        setState(() {
          _medicines = medicines;
          _onSearchChanged();
        });
      }
    } catch (e) {
      print('Error loading medicines: $e');
    }
  }

  // Update existing load methods to use the new async versions
  void _loadReminders() async {
    await _loadRemindersAsync();
  }

  void _loadMedicines() async {
    await _loadMedicinesAsync();
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text;

    setState(() {
      _filteredReminders = SearchService.filterReminders(
        _reminders,
        searchTerm,
      );
      _filteredMedicines = SearchService.filterMedicines(
        _medicines,
        searchTerm,
      );
    });
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
    if (index == 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil seleccionado')));
    }
  }

  void _deleteReminder(int id) async {
    await _dbHelper.deleteReminder(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Recordatorio eliminado')));
    _loadReminders();
  }

  // Add this new refresh method
  Future<void> _refreshData() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(Duration(milliseconds: 500));

    // Reload all data
    await Future.wait([_loadRemindersAsync(), _loadMedicinesAsync()]);

    // Show a brief confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos actualizados'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
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

          // Dark overlay when menu is open
          if (_isMenuOpen)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _toggleMenu,
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.5 * _slideAnimation.value,
                    ),
                  ),
                );
              },
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
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AlertsScreen()));
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
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar medicamentos, recordatorios...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // MQTT Sync Button Section
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sincronización Automotriz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Envía tus recordatorios al sistema del automóvil vía MQTT',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      MqttSyncButton(),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // Próximas dosis Section
                _buildSectionHeader('Próximas dosis', 'Ver todo'),
                SizedBox(height: 15),
                _filteredReminders.isEmpty
                    ? Center(
                        child: Text(
                          SearchService.getEmptyMessage(
                            _reminders,
                            _searchController.text,
                            'recordatorios',
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _filteredReminders[index];
                          return _buildDoseCard(
                            reminder,
                            'Confirmar',
                            Colors.blue,
                          );
                        },
                      ),
                SizedBox(height: 25),

                // Medicamentos Actuales Section
                _buildSectionHeader('Medicamentos Actuales', 'Ver todo'),
                SizedBox(height: 15),
                _filteredMedicines.isEmpty
                    ? Center(
                        child: Text(
                          SearchService.getEmptyMessage(
                            _medicines,
                            _searchController.text,
                            'medicamentos',
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _filteredMedicines[index];
                          return _buildMedicineCard(medicine);
                        },
                      ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTap,
        ),
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
    return Dismissible(
      key: Key(reminder.id.toString()),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit (swipe right)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CrearRecordatorioScreen(reminderToEdit: reminder),
            ),
          );
          if (result == true) {
            _loadReminders();
          }
          return false; // Do not dismiss the item
        } else {
          // Delete (swipe left)
          _deleteReminder(reminder.id!);
          return true; // Dismiss the item after deletion
        }
      },
      background: Container(
        color: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
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
                    builder: (context) =>
                        ConfirmationScreen(reminder: reminder),
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
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
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
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.medication, color: Colors.white, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              medicine.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
