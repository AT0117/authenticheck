import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        return response.body;
      } else {
        throw Exception('Scraper API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to scrape URL: $e');
    }
  }
}
