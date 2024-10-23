import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_role_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pending_orders_screen.dart';
import 'screens/completed_orders_screen.dart';
import 'screens/create_order_screen.dart';
import 'screens/modify_order_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_update_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userRole = prefs.getString('userRole') ?? '';
  runApp(MyApp(isLoggedIn: isLoggedIn, userRole: userRole));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String userRole;

  const MyApp({super.key, required this.isLoggedIn, required this.userRole});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserRoleModel(),
      child: MaterialApp(
        title: 'Bohurupi CMS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: widget.isLoggedIn
            ? widget.userRole.toLowerCase() == 'admin'
                ? const AdminDashboard()
                : const UserDashboard()
            : const LoginScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/adminDashboard': (context) => const AdminDashboard(),
          '/userDashboard': (context) => const UserDashboard(),
          '/pendingOrders': (context) => const PendingOrdersScreen(),
          '/completedOrders': (context) => const CompletedOrdersScreen(),
          '/createOrder': (context) => const CreateOrderScreen(),
          '/modifyOrder': (context) => const ModifyOrderScreen(),
        },
      ),
    );
  }
}
