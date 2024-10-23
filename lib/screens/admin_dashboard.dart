import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mobile_sidebar.dart';
import '../widgets/mobile_footer_bar.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _pendingOrders = 0;
  int _completedOrders = 0;
  bool _isLoading = true;
  String _error = '';
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();


  Future<void> _fetchData() async {
    try {
      final data = await _apiService.fetchData();
      _pendingOrders = data.where((order) => order['status'] == 'Pending').length;
      _completedOrders = data.where((order) => order['status'] == 'Done').length;
    } catch (e) {
      _error = 'An error occurred: $e';
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
  }

  @override
  Widget build(BuildContext context) {
    List<NavItem> items = [
      NavItem(icon: Icons.dashboard, label: 'Home', color: Colors.purple),
      NavItem(icon: Icons.pending_actions, label: 'Pending', color: Colors.orange),
      NavItem(icon: Icons.check_circle, label: 'Completed', color: Colors.green),
      NavItem(icon: Icons.add_circle, label: 'Create', color: Colors.blue),
      NavItem(icon: Icons.edit, label: 'Modify', color: Colors.red),
    ];
    List<String> routes = ['/adminDashboard', '/pendingOrders', '/completedOrders', '/createOrder', '/modifyOrder'];

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
      drawer: const MobileSidebar(userRole: 'admin'),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/Bohurupi-Icon.png',
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 15),
                Text('Welcome!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  '"We should not give up and we should not allow the problem to defeat us." – Dr. A.P.J. Abdul Kalam\n\n There\'s no challenge you can\'t overcome.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: Colors.red))
                else
                  Column(
                    children: [
                      _buildOrderCard(
                        icon: Icons.pending_actions_rounded,
                        title: 'Total Pending Orders',
                        count: _pendingOrders,
                      ),
                      const SizedBox(height: 10),
                      _buildOrderCard(
                        icon: Icons.check_circle_rounded,
                        title: 'Total Completed Orders',
                        count: _completedOrders,
                      ),
                    ],
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

  Widget _buildOrderCard({required IconData icon, required String title, required int count}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF6C63FF),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('$count', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
