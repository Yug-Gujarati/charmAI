import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../ads/AdsVariable.dart';
import '../services/image_filter_service.dart';
import '../utils/app_constants.dart';
import '../utils/loading_screen.dart';
import '../utils/hairstyle_data.dart';
import 'coin_managment.dart';

class FaceAnalyzerProvider extends ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic>? _analysisResult;

  Map<String, dynamic>? get analysisResult => _analysisResult;
  static  String geminiApiKey = AdsVariable.ca_gemini_api_key;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool isViolatingImage = false;
  final ImageFilterService _imageFilterService = ImageFilterService();

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      _errorMessage = null;
      _analysisResult = null;
      loadingScreen.show();
    } else {
      loadingScreen.hide();
    }
    notifyListeners();
  }


  void clearResults() {
    _analysisResult = null;
    _errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> _isImageSafe(File image, [File? image2]) async {
    final isSafe = await _imageFilterService.ImageFilter(image, image2);
    if (!isSafe) {
      showLog("Image(s) rejected by content filter.");
    }
    return isSafe;
  }

  Future<void> analyzeImage(File selectedImage, BuildContext context) async {
    if (!context.mounted) {
      return;
    }

    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    _setLoading(true);

    bool isSafe = await _isImageSafe(selectedImage);


    if (!isSafe) {
      _setLoading(false);
      showLog("One or more image violate");
      showToast("Images violate our content policy, please try with other image.");
      return;
    }


    final manStyles = HairstyleData.maleHairstyles.keys.join(", ");
    final womanStyles = HairstyleData.femaleHairstyles.keys.join(", ");

    try {
      final bytes = await selectedImage.readAsBytes();
      final base64Image = await compute(base64Encode, bytes);

      // Using the 2.5 Flash Lite model for best cost/speed balance in 2026
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Use system_instruction to define the rules of the task
          'system_instruction': {
            'parts': [
              {
                'text':
                    'You are a professional hair stylist and face shape expert. Pick 3-5 hairstyles from the allowed lists that suit the user\'s detected gender and face shape.',
              },
            ],
          },
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Analyze this face. Detect gender and shape. 
                          Allowed Men's Styles: $manStyles
                          Allowed Women's Styles: $womanStyles
                          
                          Pick from the lists and return JSON:
                          {
                            "gender": "man or woman",
                            "faceShape": "oval, round, square, heart, diamond, oblong", 
                            "hairstyles": ["StyleName1", "StyleName2", "StyleName2"] 
                          }''',
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          // FORCE JSON MODE
          'generationConfig': {'response_mime_type': 'application/json'},
        }),
      );

      showLog("this is data ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showLog("this is data $data");
        // Clean JSON response from Gemini
        final String textResponse =
            data['candidates'][0]['content']['parts'][0]['text'];

        // No RegExp needed anymore!
        final result = jsonDecode(textResponse);
        showLog("After result print: $result");
        _analysisResult = result;
        _setLoading(false);
        showLog("this is befaure coin provider $result");

        await coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_ai_lab_api);


        showLog("Analysis successful: $result");
      } else {
        _setLoading(false);
        final errorData = jsonDecode(response.body);
        _errorMessage =
            errorData['error']['message'] ?? 'Unknown error occurred';
        showLog(
          "error message: $_errorMessage",
        );
        showToast("Something went wrong, please try again");
      }
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString();
      showToast("Something went wrong, please try again");
    }
  }
}
