import 'dart:convert';
import 'dart:io';

void main() async {
  // Read the .env file manually
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found.');
    return;
  }
  
  final lines = envFile.readAsLinesSync();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length).trim();
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: GEMINI_API_KEY is empty in .env');
    return;
  }

  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();

  if (response.statusCode == 200) {
    final data = jsonDecode(responseBody);
    final models = data['models'] as List;
    print('Available Models for your API Key:');
    for (var model in models) {
      print('- ${model['name']} (Supports generation: ${model['supportedGenerationMethods']?.contains('generateContent')})');
    }
  } else {
    print('Failed to fetch models. Status: ${response.statusCode}');
    print('Response: $responseBody');
  }
}
