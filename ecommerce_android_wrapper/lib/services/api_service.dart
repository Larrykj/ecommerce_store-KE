import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator connecting to localhost Rails
  // Or replace with production URL e.g. 'https://ecommerce-rails-app.onrender.com'
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  /// Fetch a response from the new Rails AI Controller
  static Future<String> chatWithAi(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'No reply from AI.';
      } else {
        return 'Error: AI service is currently unavailable. (${response.statusCode})';
      }
    } catch (e) {
      return 'Network Error: Could not reach the server.';
    }
  }

  /// Fetch products from the fast, cached Rails API
  static Future<List<dynamic>> getProducts({int limit = 10, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit&offset=$offset'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: Could not reach the server to fetch products. $e');
    }
  }

  /// Create a native Stripe PaymentIntent using Rails
  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create_intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: Could not reach the server. $e');
    }
  }
}
