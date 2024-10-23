import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final Map<String, dynamic> _orderDetails = {
    'status': 'Pending',
    'orderstatus': 'Prepaid',
    'courier': 'Delivery',
    'shipstatus': 'Not Shipped',
    'name': '',
    'details': 'Pure Cotton',
    'colour': 'Black',
    'size': '',
    'qty': 1,
    'image': '',
    'downloaddesign': '',
  };

  final Map<String, Map<String, dynamic>> _fieldConfigs = {
    'status': {
      'label': 'Status',
      'icon': Icons.pending_actions,
      'color': Colors.blue,
      'items': ['Pending', 'Processing', 'Shipped', 'Delivered'],
    },
    'orderstatus': {
      'label': 'Order Status',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'items': ['Prepaid', 'COD'],
    },
    'courier': {
      'label': 'Courier',
      'icon': Icons.local_shipping,
      'color': Colors.orange,
      'items': ['Delivery', 'Xpressbees', 'Other'],
    },
    'shipstatus': {
      'label': 'Ship Status',
      'icon': Icons.local_shipping_outlined,
      'color': Colors.purple,
      'items': ['Not Shipped', 'Shipped', 'In Transit'],
    },
    'name': {
      'label': 'Customer Name',
      'icon': Icons.person,
      'color': Colors.teal,
      'isTextField': true,
    },
    'details': {
      'label': 'Product Details',
      'icon': Icons.inventory_2,
      'color': Colors.indigo,
      'items': ['Pure Cotton', 'Full Sleeve', 'Poly Cotton', 'Polyester', 'Mobile Cover', 'Coffee Mug'],
    },
    'colour': {
      'label': 'Colour',
      'icon': Icons.color_lens,
      'color': Colors.pink,
      'items': ['Black', 'White', 'Blue', 'Green', 'Maroon', 'Yellow', 'None'],
    },
    'size': {
      'label': 'Size/Model',
      'icon': Icons.straighten,
      'color': Colors.amber,
      'isTextField': true,
    },
    'qty': {
      'label': 'Quantity',
      'icon': Icons.numbers,
      'color': Colors.deepOrange,
      'isTextField': true,
      'isNumber': true,
    },
    'image': {
      'label': 'Product Image URL',
      'icon': Icons.image,
      'color': Colors.cyan,
      'isTextField': true,
    },
    'downloaddesign': {
      'label': 'Download Design URL',
      'icon': Icons.download,
      'color': Colors.brown,
      'isTextField': true,
    },
  };

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _apiService.createOrder(_orderDetails);
        _showMessage('Order created successfully!', Colors.green);
        _formKey.currentState!.reset();
      } catch (e) {
        _showMessage('Error creating order: $e', Colors.red);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildField(String key, Map<String, dynamic> config) {
    Widget field;
    if (config['isTextField'] == true) {
      field = TextFormField(
        decoration: _getInputDecoration('Enter ${config['label'].toLowerCase()}'),
        style: GoogleFonts.poppins(fontSize: 12),
        keyboardType: config['isNumber'] == true ? TextInputType.number : TextInputType.text,
        initialValue: config['isNumber'] == true ? _orderDetails[key].toString() : null,
        onSaved: (value) => _orderDetails[key] = config['isNumber'] == true 
            ? int.tryParse(value ?? '') ?? 1 
            : value,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter ${config['label'].toLowerCase()}';
          if (config['isNumber'] == true) {
            final num = int.tryParse(value);
            if (num == null || num <= 0) return 'Please enter a valid number';
          }
          return null;
        },
      );
    } else {
      field = DropdownButtonFormField<String>(
        value: _orderDetails[key],
        decoration: _getInputDecoration('Select ${config['label'].toLowerCase()}'),
        items: config['items'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _orderDetails[key] = value),
        validator: (value) => value == null || value.isEmpty 
            ? 'Please select ${config['label'].toLowerCase()}' 
            : null,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 1),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: config['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config['icon'], color: config['color'], size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  config['label'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            field,
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFf3e7e9), Color(0xFFe3eeff), Color(0xFFe3eeff)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Create New Order',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.purple[700],
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  for (var i = 0; i < _fieldConfigs.keys.length; i += 2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _fieldConfigs.keys.elementAt(i),
                            _fieldConfigs.values.elementAt(i),
                          ),
                        ),
                        if (i + 1 < _fieldConfigs.length) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildField(
                              _fieldConfigs.keys.elementAt(i + 1),
                              _fieldConfigs.values.elementAt(i + 1),
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.pink[400]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple[200]!,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Order',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
}