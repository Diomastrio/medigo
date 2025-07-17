import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:medigo/screens/home_screen.dart';
import 'package:medigo/screens/automotive_home_screen.dart'; // Add this import
import './screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  await AndroidAlarmManager.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGO',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: FutureBuilder<bool>(
        future: _isRunningOnAutomotive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando MediGO...'),
                  ],
                ),
              ),
            );
          }
          
          // If running on Android Automotive, go directly to AutomotiveHomeScreen
          if (snapshot.data == true) {
            return AutomotiveHomeScreen();
          }
          
          // Otherwise, show the normal auth flow
          return AuthScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _isRunningOnAutomotive() async {
    try {
      const platform = MethodChannel('com.example.medigo/automotive');
      final bool isAutomotive = await platform.invokeMethod('isAutomotive');
      return isAutomotive;
    } catch (e) {
      // Fallback: assume not automotive if method channel fails
      print('Error checking automotive mode: $e');
      return false;
    }
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegistering = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Save user data to local storage
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', _emailController.text);
    await prefs.setString('user_password', _passwordController.text);
    await prefs.setString('user_name', _nameController.text);
  }

  // Load user data from local storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('user_email') ?? '';
      _passwordController.text = prefs.getString('user_password') ?? '';
      _nameController.text = prefs.getString('user_name') ?? '';
    });
  }

  // Validate login
  Future<void> _validateLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('user_name') ?? '';
    final storedPassword = prefs.getString('user_password') ?? '';

    if (_nameController.text == storedName &&
        _passwordController.text == storedPassword) {
      // Login successful
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      // Login failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nombre o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle form submission
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (isRegistering) {
        await _saveUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isRegistering = false;
        });
      } else {
        await _validateLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade200, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header with logo and title
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade100],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background medical image placeholder
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/pill.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Overlay with logo and text
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'MediGO',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Nunca te saltes una dosis nuevamente',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Form Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with toggle button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isRegistering ? 'Registrate' : 'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isRegistering
                                        ? Icons.login
                                        : Icons.person_add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isRegistering = !isRegistering;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Form fields
                          if (isRegistering) ...[
                            _buildTextField(
                              controller: _emailController,
                              label: 'Correo',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Por favor ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre(s)',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                          ],

                          SizedBox(height: 30),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                isRegistering ? 'Unirse' : 'Entrar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          // Toggle text
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isRegistering = !isRegistering;
                                });
                              },
                              child: Text(
                                isRegistering
                                    ? '¿Ya tienes cuenta? Inicia sesión'
                                    : '¿No tienes cuenta? Regístrate',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
