import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/authenticity_result.dart';

class LlmService {
  Future<AuthenticityResult> analyzeProduct(String scrapedText) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key not found');
    }

    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final prompt = '''
You are an expert product authenticity analyzer. Based on the following raw HTML/text from an Amazon or Flipkart product page, evaluate the counterfeit risk, fake reviews, and price anomalies.
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
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text != null) {
        final json = jsonDecode(text);
        return AuthenticityResult.fromJson(json);
      } else {
        throw Exception('LLM returned null response');
      }
    } catch (e) {
      throw Exception('LLM inference failed: $e');
    }
  }
}
