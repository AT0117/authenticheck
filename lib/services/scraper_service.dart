import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/parser.dart' as html_parser;

class ScraperService {
  Future<String> scrapeProduct(String url) async {
    final apiKey = dotenv.env['SCRAPER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Scraper API Key not found');
    }

    final scraperUrl = Uri.parse('http://api.scraperapi.com?api_key=$apiKey&url=${Uri.encodeComponent(url)}');
    
    try {
      final response = await http.get(scraperUrl);
      if (response.statusCode == 200) {
        return _sanitizeHtml(response.body);
      } else {
        throw Exception('Scraper API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to scrape URL: $e');
    }
  }

  String _sanitizeHtml(String rawHtml) {
    // 1. Parse the HTML document
    final document = html_parser.parse(rawHtml);

    // 2. Remove unwanted tags to strip out non-visible clutter
    final tagsToRemove = ['script', 'style', 'noscript', 'svg', 'nav', 'footer', 'iframe', 'header', 'aside'];
    for (var tag in tagsToRemove) {
      final elements = document.querySelectorAll(tag);
      for (var element in elements) {
        element.remove();
      }
    }

    // 3. Extract text from body
    final bodyText = document.body?.text ?? '';

    // 4. Collapse consecutive whitespaces and newlines
    final collapsedText = bodyText.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 5. Truncate to a maximum of 4000 characters
    if (collapsedText.length > 4000) {
      return collapsedText.substring(0, 4000);
    }
    
    return collapsedText;
  }
}
