import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/mobile_sidebar.dart';
import '../widgets/mobile_footer_bar.dart';
import '../services/api_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with SingleTickerProviderStateMixin {
  int _pendingOrders = 0;
  int _completedOrders = 0;
  bool _isLoading = true;
  String _error = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final data = await _apiService.fetchData();
      _pendingOrders = data.where((order) => order['status'] == 'Pending').length;
      _completedOrders = data.where((order) => order['status'] == 'Done').length;
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<NavItem> items = [
      NavItem(icon: Icons.home, label: 'Home', color: Colors.blue),
      NavItem(icon: Icons.pending_actions, label: 'Pending', color: Colors.orange),
      NavItem(icon: Icons.check_circle, label: 'Completed', color: Colors.green),
    ];
    List<String> routes = ['/userDashboard', '/pendingOrders', '/completedOrders'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: Text(
          'Bohurupi CMS',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const MobileSidebar(userRole: 'user'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF5A52CC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildGlassyContainer(
                  child: Image.asset(
                    'assets/Bohurupi-Icon.png',
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 15),
                Text('Welcome to Bohurupi CMS!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  '"Dream is not that which you see while sleeping; it is something that does not let you sleep." – Dr. A.P.J. Abdul Kalam\n\nLet\'s work together towards turning your dreams into reality!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red))
                else
                  FadeTransition(
                    opacity: _animation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOrderCard(
                          icon: Icons.pending_actions_rounded,
                          title: 'Pending Orders',
                          count: _pendingOrders,
                          color: Colors.orange,
                        ),
                        _buildOrderCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Completed Orders',
                          count: _completedOrders,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MobileFooterBar(
        items: items,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index < routes.length) {
            Navigator.pushNamed(context, routes[index]);
          }
        },
      ),
    );
  }

  Widget _buildGlassyContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildOrderCard({required IconData icon, required String title, required int count, required Color color}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // TODO: Implement navigation or action when card is tapped
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
      },
      child: _buildGlassyContainer(
        child: Container(
          width: 152,
          height: 172,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text('$count', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
