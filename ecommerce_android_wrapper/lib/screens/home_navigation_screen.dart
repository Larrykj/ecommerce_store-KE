import 'package:flutter/material.dart';
import 'package:ecommerce_android_wrapper/main.dart'; // import StoreWebView
import 'native_home_screen.dart';
import 'ai_chat_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;
  
  // Define the list of screens
  final List<Widget> _screens = [
    const NativeHomeScreen(),
    const StoreWebView(initialUrl: 'https://ecommerce-rails-app.onrender.com/products'), // Products WebView
    const StoreWebView(initialUrl: 'https://ecommerce-rails-app.onrender.com/cart'),     // Cart WebView
    const StoreWebView(initialUrl: 'https://ecommerce-rails-app.onrender.com/profile'),  // Profile WebView
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensure all icons show if > 3 items
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        tooltip: 'AI Chat Advisor',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()));
        },
        child: const Icon(Icons.auto_awesome_rounded),
      ),
    );
  }
}
