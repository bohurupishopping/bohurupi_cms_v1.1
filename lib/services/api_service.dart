import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://sheetlabs.com/BSIN/mitra';
  final String username = 'pritam@bohurupi.com';
  final String token = 'c97f0fb8-ab3b-4749-baf2-c7dee759926c';

  Future<List<dynamic>> fetchData() async {
    final basicAuth = base64Encode(utf8.encode('$username:$token'));
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $basicAuth',
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderDetails) async {
    final basicAuth = base64Encode(utf8.encode('$username:$token'));
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $basicAuth',
      }, body: jsonEncode([orderDetails]));

      if (response.statusCode != 204) {
        throw Exception('Failed to create order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating order: $e');
    }
  }
}
