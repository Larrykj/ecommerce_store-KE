import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Production URL used by default.
  // For local development with Android Emulator, use: http://10.0.2.2:3000/api/v1
  static const String _productionUrl = 'https://ecommerce-rails-app.onrender.com/api/v1';
  static const String _localUrl = 'http://10.0.2.2:3000/api/v1';

  // Toggle this flag for local development vs production
  static const bool _useLocalServer = false;

  static String get baseUrl => _useLocalServer ? _localUrl : _productionUrl;

  /// Fetch a response from the Rails AI Controller
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
      } else if (response.statusCode == 429) {
        return 'Too many requests. Please wait a moment and try again.';
      } else {
        return 'Error: AI service is currently unavailable. (${response.statusCode})';
      }
    } catch (e) {
      return 'Network Error: Could not reach the server.';
    }
  }

  /// Fetch products from the fast, cached Rails API
  static Future<List<dynamic>> getProducts({int limit = 10, int offset = 0, String? categoryId, String? search}) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (categoryId != null) 'category_id': categoryId,
        if (search != null) 'search': search,
      };
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: Could not reach the server. $e');
    }
  }

  /// Fetch categories from the Rails API
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['categories'] ?? [];
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: Could not fetch categories. $e');
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
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again shortly.');
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: Could not reach the server. $e');
    }
  }
}
