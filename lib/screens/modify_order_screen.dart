import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModifyOrderScreen extends StatefulWidget {
  const ModifyOrderScreen({Key? key}) : super(key: key);

  @override
  State<ModifyOrderScreen> createState() => _ModifyOrderScreenState();
}

class _ModifyOrderScreenState extends State<ModifyOrderScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String _error = '';
  
  final String username = "pritam@bohurupi.com";
  final String token = "c97f0fb8-ab3b-4749-baf2-c7dee759926c";
  final String baseUrl = "https://sheetlabs.com/BSIN/mitra";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        setState(() => _orders = List<Map<String, dynamic>>.from(jsonDecode(response.body)));
      } else {
        setState(() => _error = 'Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Failed to load orders: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateOrderStatus(int orderId, String currentStatus) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: jsonEncode([
          {"__id": orderId, "status": currentStatus == 'Done' ? 'Pending' : 'Done'}
        ]),
      );

      if (response.statusCode == 204) {
        setState(() {
          _orders = _orders.map((order) => order['__id'] == orderId 
            ? {...order, 'status': currentStatus == 'Done' ? 'Pending' : 'Done'} 
            : order).toList();
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to update order: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteOrder(int orderId) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: _getHeaders(),
        body: jsonEncode([{"__id": orderId}]),
      );

      if (response.statusCode == 204) {
        setState(() => _orders.removeWhere((order) => order['__id'] == orderId));
      }
    } catch (e) {
      setState(() => _error = 'Failed to delete order: $e');
    }
    setState(() => _isLoading = false);
  }

  Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$token'))}',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Edit Orders', 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            fontSize: 24, 
            color: Colors.white
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFC796), Color(0xFFFF6B95)],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
            ? Center(child: Text(_error, style: TextStyle(color: Colors.red)))
            : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) => _OrderCard(
                  order: _orders[index],
                  onUpdate: _updateOrderStatus,
                  onDelete: _deleteOrder,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrders,
        backgroundColor: const Color(0xFFFF6B95),
        child: const Icon(Icons.refresh),
      ).animate().scale(duration: 300.ms),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(int, String) onUpdate;
  final Function(int) onDelete;

  const _OrderCard({
    required this.order,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildImage(),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails()),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC796), Color(0xFFFF6B95)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Order #${order['__id']}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(order['status'] ?? '',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF6B95),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return CircleAvatar(
      radius: 40,
      backgroundImage: order['image'] != null 
        ? NetworkImage(order['image'])
        : null,
      child: order['image'] == null 
        ? const Icon(Icons.image_not_supported)
        : null,
    );
  }

  Widget _buildDetails() {
    final fields = {
      FontAwesomeIcons.user: 'name',
      FontAwesomeIcons.info: 'details',
      FontAwesomeIcons.paintBrush: 'colour',
      FontAwesomeIcons.ruler: 'size',
      FontAwesomeIcons.boxOpen: 'qty',
      FontAwesomeIcons.truck: 'courier',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.entries.map((entry) => Row(
        children: [
          Icon(entry.key, size: 12, color: const Color(0xFFFF6B95)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${entry.value}: ${order[entry.value] ?? ''}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => onUpdate(order['__id'], order['status']),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Update'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => onDelete(order['__id']),
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }
}