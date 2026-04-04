import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'package:ecommerce_android_wrapper/main.dart';

// ---------------------------------------------------------------------------
// WebView Platform Mock — covers ALL abstract/unimplemented methods
// ---------------------------------------------------------------------------
class _MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => _MockController(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _MockWebViewWidget(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _MockNavDelegate(params);

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) => throw UnimplementedError();
}

class _MockController extends PlatformWebViewController {
  _MockController(super.params) : super.implementation();

  @override Future<void> setJavaScriptMode(JavaScriptMode m) async {}
  @override Future<void> setBackgroundColor(Color c) async {}
  @override Future<void> loadRequest(LoadRequestParams p) async {}
  @override Future<bool> canGoBack() async => false;
  @override Future<void> goBack() async {}
  @override Future<void> reload() async {}

  // The platform-level method webview_flutter calls during setNavigationDelegate
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
}

class _MockWebViewWidget extends PlatformWebViewWidget {
  _MockWebViewWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _MockNavDelegate extends PlatformNavigationDelegate {
  _MockNavDelegate(super.params) : super.implementation();
  @override Future<void> setOnPageStarted(PageEventCallback f) async {}
  @override Future<void> setOnPageFinished(PageEventCallback f) async {}
  @override Future<void> setOnWebResourceError(WebResourceErrorCallback f) async {}
  @override Future<void> setOnNavigationRequest(NavigationRequestCallback f) async {}
  @override Future<void> setOnUrlChange(UrlChangeCallback f) async {}
  @override Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback f) async {}
  @override Future<void> setOnHttpError(HttpResponseErrorCallback f) async {}
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------
Stream<List<ConnectivityResult>> _silentStream() =>
    StreamController<List<ConnectivityResult>>.broadcast().stream;

Widget _testApp({Stream<List<ConnectivityResult>>? connectivity}) =>
    MaterialApp(
      home: StoreWebView(
        connectivityStream: connectivity ?? _silentStream(),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  setUpAll(() {
    WebViewPlatform.instance = _MockWebViewPlatform();
  });

  testWidgets('StoreWebView renders a Scaffold', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('AppBar shows E-Commerce KE title', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.text('E-Commerce KE'), findsOneWidget);
  });

  testWidgets('AppBar has a shopping bag icon', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.byIcon(Icons.shopping_bag_rounded), findsAtLeastNWidgets(1));
  });

  testWidgets('AppBar has a refresh button', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });

  testWidgets('MyApp builds with correct MaterialApp title', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, equals('E-Commerce KE'));
  });

  testWidgets('Offline screen is hidden when connected', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();
    expect(find.text('No Internet Connection'), findsNothing);
  });

  testWidgets('Offline screen appears when connectivity emits none',
      (tester) async {
    final ctrl = StreamController<List<ConnectivityResult>>.broadcast();
    await tester.pumpWidget(_testApp(connectivity: ctrl.stream));
    await tester.pump();

    // Emit offline event
    ctrl.add([ConnectivityResult.none]);
    await tester.pump();

    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await ctrl.close();
  });
}
