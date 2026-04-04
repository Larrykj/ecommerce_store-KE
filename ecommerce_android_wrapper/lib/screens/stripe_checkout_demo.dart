import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/api_service.dart';

class StripeCheckoutDemo extends StatefulWidget {
  const StripeCheckoutDemo({Key? key}) : super(key: key);

  @override
  State<StripeCheckoutDemo> createState() => _StripeCheckoutDemoState();
}

class _StripeCheckoutDemoState extends State<StripeCheckoutDemo> {
  bool _isLoading = false;

  Future<void> _handleCheckout() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Payment Intent from Rails API
      final intentData = await ApiService.createPaymentIntent('5000', 'kes');
      
      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentData['paymentIntent'],
          merchantDisplayName: 'E-Commerce KE',
          style: ThemeMode.system,
        )
      );

      // 3. Display the Native Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Success handling
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
      );

    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Cancelled: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
        ? const CircularProgressIndicator()
        : ElevatedButton.icon(
            onPressed: _handleCheckout,
            icon: const Icon(Icons.payment_rounded),
            label: const Text('Checkout with Stripe (Native)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
}
