import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../services/image_filter_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_constants.dart' as Fluttertoast;
import '../utils/navigation.dart';
import '../utils/loading_screen.dart';
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class DatingRedyImageProvider extends ChangeNotifier{
  bool isLoading = false;
  File? resultImage;
  String? errorMessage;
  bool isViolatingImage = false;
  final ImageFilterService _imageFilterService = ImageFilterService();

  static String geminiApiKey = AdsVariable.ca_gemini_api_key;

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      errorMessage = null;
      resultImage = null;
      loadingScreen.show();
    } else {
      loadingScreen.hide();
    }
    notifyListeners();
  }

  void clearResults() {
    resultImage = null;
    errorMessage = null;
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

  /// Enhance image using Gemini API
  Future<void> datingImageGenerator(File selectedImage, BuildContext context) async {
    _setLoading(true);

    bool isSafe = await _isImageSafe(selectedImage);
    if (!isSafe) {
      _setLoading(false);
      showLog("One or more image violate");
      showToast("Images violate our content policy, please try with other image.");
      return;
    }

    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    try {
      final userBytes = await selectedImage.readAsBytes();
      final userBase64 = await compute(base64Encode, userBytes);

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$geminiApiKey',
      );

      showLog("Selected Image Size: ${userBytes.length} bytes");

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                '''Edit this uploaded image into a dating profile portrait.

Strictly preserve exact face, exact face identity, facial structure, skin tone, and body proportions.

Enhance with:
modern hairstyle matching face shape,
flattering casual or smart-casual outfit (t-shirt, shirt, knitwear, light jacket anything good; avoid business suit),
cinematic portrait lighting,
natural confident expression, and pose,
premium blurred lifestyle background (cafe, studio, sunset park, apartment, skyline).

Maintain natural skin texture, sharp eyes, shallow depth-of-field, professional framing.

Output ultra-realistic DSLR portrait, vertical 9:16, minimum 2048×4096 resolution.''',
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": userBase64},
              },
            ],
          },
        ],
        "generationConfig": {
          "responseModalities": ["IMAGE"],
          "temperature": 0.2,
          "topP": 0.8,
          "topK": 32
        },
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      showLog("Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        showLog("Response data decoded successfully");

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'] as List;

          // Look for the part that contains 'inline_data' or 'inlineData'
          final imagePart = parts.cast<Map<String, dynamic>?>().firstWhere(
                (part) =>
            part?.containsKey('inline_data') == true ||
                part?.containsKey('inlineData') == true,
            orElse: () => null,
          );

          if (imagePart != null) {
            final inlineData =
                imagePart['inline_data'] ?? imagePart['inlineData'];
            if (inlineData != null && inlineData['data'] != null) {
              final String base64Data = inlineData['data'];
              showLog(
                "Image data found in response. Length: ${base64Data.length}",
              );

              final file = await _saveImageLocally(base64Data);
              resultImage = file;


              _setLoading(false);


              // Deduct coins
              await coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_gemini_api);

              // Navigate to result screen
              if (context.mounted && resultImage != null) {
                AppNavigation.NavigationPush(
                  context,
                  VirtualTryOnResultScreen(resultImage: resultImage!),
                );
              }

              showToast("Enhancement successful!");
              return;
            }
          }

          showLog("No inlineData (image) found in response parts.");
          _setLoading(false);
          errorMessage = "No image returned by AI.";
          showToast("Something went wrong, please try again letter");
        } else {
          showLog("No candidates in response.");
          _setLoading(false);
          errorMessage = "No response candidates.";
          showToast("Something went wrong, please try again letter");
        }
      } else {
        _setLoading(false);
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['error']['message'] ??
                  'Unknown error ${response.statusCode}';
        } catch (_) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        showLog("API Error: $errorMessage");
        showToast("Something went wrong, please try again letter");
      }
    } catch (e) {
      showLog("Error in enhanceImage: $e");
      _setLoading(false);
      errorMessage = e.toString();
      showToast("Something went wrong, please try again letter");
    }
  }

  Future<File> _saveImageLocally(String base64String) async {
    try {
      showLog("Starting image save process");

      // Remove data URL prefix if present (data:image/jpeg;base64,)
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      // Clean all whitespace, newlines, etc.
      base64String = base64String
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '')
          .replaceAll('\t', '');

      try {
        base64String = Uri.decodeComponent(base64String);
      } catch (e) {
        showLog("No URL encoding detected");
      }

      if (!_isValidBase64(base64String)) {
        throw Exception("Invalid base64 string format");
      }

      final bytes = await compute(base64Decode, base64String);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      final prefs = await SharedPreferences.getInstance();
      final List<String> savedImages =
          prefs.getStringList('saved_generated_images') ?? [];
      savedImages.insert(0, file.path);

      if (savedImages.length > 50) {
        savedImages.removeRange(50, savedImages.length);
      }

      await prefs.setStringList('saved_generated_images', savedImages);

      showLog("Enhanced image saved locally: ${file.path}");
      return file;
    } catch (e) {
      showLog("Error saving image: $e");
      throw Exception("Failed to save image: $e");
    }
  }

  bool _isValidBase64(String str) {
    try {
      final base64RegExp = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return base64RegExp.hasMatch(str);
    } catch (e) {
      return false;
    }
  }
}
