import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_role_model.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({Key? key}) : super(key: key);

  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userRoleModel = Provider.of<UserRoleModel>(context);
    final userRole = userRoleModel.userRole;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 0) {
          if (userRole.toLowerCase() == 'admin') {
            Navigator.pushReplacementNamed(context, '/adminDashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/userDashboard');
          }
        } else if (index == 1) {
          Navigator.pushNamed(context, '/pendingOrders');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/completedOrders');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/createOrder');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pending),
          label: 'Pending Orders',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.check_circle),
          label: 'Completed Orders',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.add),
          label: 'Create Order',
        ),
      ],
    );
  }
}
