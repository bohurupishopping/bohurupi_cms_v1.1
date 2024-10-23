import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_role_model.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';
import '../widgets/mobile_sidebar.dart';
import '../widgets/mobile_footer_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRoleModel>(context).userRole;
    List<NavItem> items = [];
    List<String> routes = [];

    if (userRole == 'user') {
      items = [
        NavItem(icon: Icons.home, label: 'Home', color: Colors.blue),
        NavItem(icon: Icons.pending_actions, label: 'Pending', color: Colors.orange),
        NavItem(icon: Icons.check_circle, label: 'Completed', color: Colors.green),
      ];
      routes = ['/userDashboard', '/pendingOrders', '/completedOrders'];
    } else if (userRole == 'admin') {
      items = [
        NavItem(icon: Icons.dashboard, label: 'Home', color: Colors.purple),
        NavItem(icon: Icons.pending_actions, label: 'Pending', color: Colors.orange),
        NavItem(icon: Icons.check_circle, label: 'Completed', color: Colors.green),
        NavItem(icon: Icons.add_circle, label: 'Create', color: Colors.blue),
        NavItem(icon: Icons.edit, label: 'Modify', color: Colors.red),
      ];
      routes = ['/adminDashboard', '/pendingOrders', '/completedOrders', '/createOrder', '/modifyOrder'];
    }

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
      drawer: MobileSidebar(userRole: userRole),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: userRole == 'user' ? const UserDashboard() : const AdminDashboard(),
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
}
