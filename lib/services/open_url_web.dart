import 'package:web/web.dart' as web;

/// Open [url] in a new browser tab.
void openUrl(String url) {
  web.window.open(url, '_blank');
}
