import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'screens/home_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce KE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2E6E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeNavigationScreen(),

    );
  }
}

class StoreWebView extends StatefulWidget {
  const StoreWebView({
    super.key,
    this.initialUrl = 'https://ecommerce-rails-app.onrender.com',
    Stream<List<ConnectivityResult>>? connectivityStream,
  }) : _connectivityStream = connectivityStream;

  final String initialUrl;
  final Stream<List<ConnectivityResult>>? _connectivityStream;

  @override
  State<StoreWebView> createState() => _StoreWebViewState();
}

class _StoreWebViewState extends State<StoreWebView> {
  static const String appUrl = 'https://ecommerce-rails-app.onrender.com';

  late final WebViewController _controller;
  bool _loading = true;
  bool _hasError = false;
  bool _isOffline = false;
  String _errorMessage = '';

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _listenToConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _listenToConnectivity() {
    final stream =
        widget._connectivityStream ?? Connectivity().onConnectivityChanged;
    _connectivitySubscription = stream.listen(
      (results) {
        final isOffline =
            results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        if (mounted) {
          setState(() => _isOffline = isOffline);
          if (!isOffline && _hasError) {
            _retryLoad();
          }
        }
      },
    );
  }

  void _initWebViewController() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFF0D47A1))
          ..setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (mounted) setState(() { _loading = true; _hasError = false; });
              },
              onPageFinished: (_) {
                if (mounted) setState(() => _loading = false);
              },
              onWebResourceError: (error) {
                if (error.isForMainFrame ?? true) {
                  if (mounted) {
                    setState(() {
                      _loading = false;
                      _hasError = true;
                      _errorMessage = error.description;
                    });
                  }
                }
              },
              onNavigationRequest: (request) async {
                final uri = Uri.parse(request.url);

                // Stripe checkout — always open in external browser
                if (uri.host.contains('checkout.stripe.com') ||
                    uri.host.contains('js.stripe.com') ||
                    uri.host.contains('hooks.stripe.com')) {
                  await _launchUrl(uri);
                  return NavigationDecision.prevent;
                }

                // Internal links OR OAuth Flows (Google/GitHub) stay inside the WebView
                final appHost = Uri.parse(appUrl).host;
                if (uri.host == appHost || 
                    uri.host.contains('localhost') ||
                    uri.host.contains('accounts.google.com') ||
                    uri.host.contains('github.com')) {
                  return NavigationDecision.navigate;
                }

                // Everything else (social links, outside sites) opens in external device browser
                await _launchUrl(uri);
                return NavigationDecision.prevent;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for URIs like mailto, tel without properly configured intents
        await launchUrl(url); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _retryLoad() {
    setState(() { _hasError = false; _loading = true; });
    _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Exit App?'),
                content: const Text('Do you want to exit E-Commerce KE?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_rounded, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'E-Commerce KE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            if (_isOffline)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.wifi_off_rounded, color: Colors.amber),
              ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: _retryLoad,
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              if (!_isOffline && !_hasError)
                WebViewWidget(controller: _controller),
              if (_isOffline)
                _buildStatusScreen(
                  icon: Icons.wifi_off_rounded,
                  iconColor: Colors.blueGrey.shade300,
                  title: 'No Internet Connection',
                  subtitle: 'Please check your network settings and try again.',
                  buttonLabel: 'Retry',
                  onButton: _retryLoad,
                ),
              if (!_isOffline && _hasError)
                _buildStatusScreen(
                  icon: Icons.error_outline_rounded,
                  iconColor: Colors.orange.shade300,
                  title: 'Something Went Wrong',
                  subtitle: _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Unable to load the page. Please try again.',
                  buttonLabel: 'Try Again',
                  onButton: _retryLoad,
                ),
              if (_loading && !_isOffline && !_hasError)
                Container(
                  color: const Color(0xFF0D47A1),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.amber,
                          size: 64,
                        ),
                        SizedBox(height: 24),
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading E-Commerce KE…',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusScreen({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onButton,
  }) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onButton,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
