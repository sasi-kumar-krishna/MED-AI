import 'dart:convert';
import 'dart:io';

import 'package:firebase_vertexai/firebase_vertexai.dart';

class ApiService {
  static Future<Map<String, dynamic>> uploadPrescription(File image) async {
    try {
      // Initialize Vertex AI
      // The API key is now handled by firebase_options.dart
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
      );

      // Read image bytes
      final imageBytes = await image.readAsBytes();

      // Create prompt for prescription analysis
      final prompt = '''
Analyze this medical prescription image and extract the following information in JSON format:

{
  "problem": "The medical condition or problem diagnosed",
  "medicines": [
    {
      "name": "Medicine name",
      "dosage": "Dosage information (e.g., 500mg, 2 tablets)",
      "frequency": "How often to take (e.g., twice daily, after meals)",
      "use": "What this medicine is used for / its purpose"
    }
  ]
}

Please be thorough and extract all visible medicines from the prescription. If any information is not clearly visible, use "Not specified" for that field.
''';

      // Create content with image and text
      final content = [
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ]),
      ];

      // Generate response
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';

      // Extract JSON from response (handling markdown code blocks)
      String jsonString = responseText;
      if (jsonString.contains('```json')) {
        jsonString = jsonString.split('```json')[1].split('```')[0].trim();
      } else if (jsonString.contains('```')) {
        jsonString = jsonString.split('```')[1].split('```')[0].trim();
      }

      // Parse JSON response
      final Map<String, dynamic> result = jsonDecode(jsonString);
      return result;
    } catch (e) {
      print('Error analyzing prescription: $e');
      // Return error response
      return {
        'problem': 'Error analyzing prescription: ${e.toString()}',
        'medicines': [],
      };
    }
  }
}
