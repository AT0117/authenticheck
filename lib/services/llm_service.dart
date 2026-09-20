import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/authenticity_result.dart';

class LlmService {
  Future<AuthenticityResult> analyzeProduct(String scrapedText) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Groq API Key not found');
    }

    final prompt =
        '''
You are an expert product authenticity analyzer. Based on the following raw text from an Amazon or Flipkart product page, evaluate the counterfeit risk, fake reviews, and price anomalies.
Return a JSON object exactly with these keys:
{
  "authenticity_score": int (0-100, where 100 means highly authentic, 0 means definite counterfeit),
  "verdict": "string" (A concise, punchy final verdict),
  "price_anomaly": bool,
  "risk_factors": ["string"] (List of potential red flags or positive indicators)
}

Product Page Data:
$scrapedText
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-20b',
          'temperature': 0.2,
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a strict e-commerce authenticity auditor. Always respond with valid JSON adhering to: {"authenticity_score": int, "verdict": "string", "price_anomaly": bool, "risk_factors": ["string"]}.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonResult = jsonDecode(content);
        return AuthenticityResult.fromJson(jsonResult);
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate Limited (429): Too many requests to Groq API. Please wait a moment.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Model access error - please update configuration');
      } else {
        throw Exception(
          'Groq API failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Failed to parse JSON response from LLM.');
      }
      throw Exception('LLM inference failed: $e');
    }
  }
}
