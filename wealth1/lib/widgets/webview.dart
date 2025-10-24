import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String? url;
  final String? title;
  final Function(double height)? onHeightChanged;

  const WebViewScreen({super.key, this.url, this.title, this.onHeightChanged});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController webViewController;
  bool isLoading = true;
  String? uId = '679b2425c843db2c70235a47';

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getString('userId');

    debugPrint('Token $authToken');
    debugPrint('UserId $userId');

    uId = userId;
    debugPrint('Check Token $uId');

    if (authToken == null || userId == null) {
      debugPrint(
          'ERROR: No auth token or userId available for fetching transactions');
      return;
    }
  }

  /// Extract height from query param if available
  double? _extractHeightFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String? heightParam = uri.queryParameters['height'];
      debugPrint("Extract height from URL: $heightParam");

      if (heightParam != null) {
        return double.tryParse(heightParam);
      }
    } catch (e) {
      debugPrint("Error extracting height from URL: $e");
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchUserId();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
            debugPrint("Web Page started loading: $url");
          },
          onPageFinished: (String url) async {
            if (mounted) {
              setState(() {
                isLoading = false;
              });

              try {
                // First try to read height from URL param
                final extractedHeight = _extractHeightFromUrl(url);

                debugPrint("Height from final URL: $extractedHeight");

                if (extractedHeight != null && widget.onHeightChanged != null) {
                  widget.onHeightChanged!(extractedHeight.toDouble());
                  debugPrint("Height from URL param: $extractedHeight");
                } else {
                  // Fallback to DOM scrollHeight
                  // final result =
                  //     await webViewController.runJavaScriptReturningResult(
                  //         'document.documentElement.scrollHeight');
                  // final height = double.tryParse(result.toString());

                  final extractedHeight = _extractHeightFromUrl(url);

                  if (extractedHeight != null &&
                      widget.onHeightChanged != null) {
                    widget.onHeightChanged!(extractedHeight.toDouble());
                    debugPrint("Height from DOM: $extractedHeight");
                  }
                }
              } catch (e) {
                debugPrint("Error getting content height: $e");
              }
            }
            debugPrint("Web Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web Resource Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse('${widget.url}'));
  }

  @override
  void dispose() {
    debugPrint("WebViewScreen disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANT for keepAlive

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    } else {
      return WebViewWidget(controller: webViewController);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
