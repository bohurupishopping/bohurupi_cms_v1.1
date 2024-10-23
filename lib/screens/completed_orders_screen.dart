import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../utils/order_card.dart';

class CompletedOrdersScreen extends StatefulWidget {
  const CompletedOrdersScreen({Key? key}) : super(key: key);

  @override
  State<CompletedOrdersScreen> createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends State<CompletedOrdersScreen>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<dynamic> _orders = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);
    _fetchOrders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.fetchData();
      setState(() {
        _orders = data.where((order) => order['status'] == 'Done').toList();
      });
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      _refreshController.refreshCompleted();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Completed Orders',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
          ),
        ),
        child: SafeArea(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.3),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _fetchOrders,
                        child: ListView.builder(
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: OrderCard(order: order),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchOrders,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.refresh),
      ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
    );
  }
}
