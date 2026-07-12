import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../utils/app_constants.dart';
import '../utils/navigation.dart';
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class SubpriseProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isAnalyzing = false;
  File? resultImage;
  String? errorMessage;

  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? get analysisResult => _analysisResult;

  static String geminiApiKey = AdsVariable.ca_gemini_api_key;

  static final List<Map<String, dynamic>> surpriseThemes = [
    {
      "name": "Duck Rider",
      "prompt": "the subject sitting on top of a giant oversized duck like a mount, comedic scale, bright cartoon-blue sky background, exaggerated surprised or gleeful expression, absurd but photorealistic rendering",
      "overridesPose": true,
    },
    {
      "name": "Cowboy Cow Ride",
      "prompt": "the subject riding a cow like a rodeo cowboy, one arm raised in the air, dusty farm background, wide comedic grin, exaggerated action pose",
      "overridesPose": true,
    },
    {
      "name": "Baby Walker Adult",
      "prompt": "the subject's exact adult face and body sitting inside an oversized baby walker toy, wearing an oversized comedic onesie over normal body proportions, pastel nursery-style background, playful pouty baby-like expression, absurd comedic scale contrast between adult face and baby props",
      "overridesPose": true,
    },
    {
      "name": "Giant Rubber Duck Float",
      "prompt": "the subject floating in a swimming pool on a giant inflatable rubber duck, sunglasses, drink in hand, bright pool party background, relaxed goofy grin",
      "overridesPose": true,
    },
    {
      "name": "Mechanical Bull Chaos",
      "prompt": "the subject mid-air falling off a mechanical bull at a rodeo bar, arms flailing comedically, western bar background with cheering blurred crowd, shocked funny expression",
      "overridesPose": true,
    },
    {
      "name": "Giant Burger Costume",
      "prompt": "the subject wearing a giant foam burger costume with only the face visible through the bun, food-truck fair background, cheerful proud expression",
      "overridesPose": false,
    },
    {
      "name": "Dinosaur Onesie",
      "prompt": "the subject wearing a full comedic inflatable dinosaur costume, roaring pose with arms up like tiny T-rex arms, jungle-themed party background, silly exaggerated roar expression",
      "overridesPose": true,
    },
    {
      "name": "Astronaut Llama",
      "prompt": "the subject in an astronaut suit riding a llama on the moon, earth visible in the starry sky background, comedic thumbs-up pose, gleeful expression",
      "overridesPose": true,
    },
    {
      "name": "Stuck in Vending Machine",
      "prompt": "the subject's upper body comedically stuck reaching into a vending machine full of snacks, arm jammed inside, mall background, exaggerated frustrated funny expression",
      "overridesPose": true,
    },
    {
      "name": "King of Pigeons",
      "prompt": "the subject sitting on an oversized ornate throne surrounded by comedic cartoon pigeons like royal subjects, park background, exaggerated regal but ridiculous pose and expression",
      "overridesPose": true,
    },
    {
      "name": "Barrel Outfit",
      "prompt": "the subject wearing a classic cartoon wooden barrel held up by suspenders as an outfit, comedic poor-but-happy vibe, simple alley background, sheepish grin",
      "overridesPose": false,
    },
    {
      "name": "Waiter Balancing Chaos",
      "prompt": "the subject as a waiter comedically off-balance while holding an impossibly tall stack of plates and food, restaurant background, mid-stumble panicked funny expression",
      "overridesPose": true,
    },
    {
      "name": "Surfing a Watermelon",
      "prompt": "the subject surfing on a giant watermelon slice instead of a surfboard, ocean wave background, wide thrilled comedic grin, dynamic action pose",
      "overridesPose": true,
    },
    {
      "name": "Fishing a Giant Fish",
      "prompt": "the subject comedically being pulled off their feet by a giant fish on a fishing line, lake background, exaggerated strained but excited expression",
      "overridesPose": true,
    },
    {
      "name": "Disco Time Machine",
      "prompt": "the subject in an over-the-top sequined 70s disco outfit with an afro wig, colorful disco ball lighting background, exaggerated confident dance pose and grin",
      "overridesPose": true,
    },
    {
      "name": "Alien Abduction Comedy",
      "prompt": "the subject comedically being beamed up by a glowing UFO tractor beam, cornfield at night background, exaggerated startled funny expression, arms flailing",
      "overridesPose": true,
    },
    {
      "name": "Medieval Peasant Fail",
      "prompt": "the subject standing and dressed as a bumbling medieval peasant, holding a pitchfork upside down in one hand, comedic castle village background, confused goofy expression",
      "overridesPose": false,
    },
    {
      "name": "Superhero Cape Fail",
      "prompt": "the subject in a homemade-looking superhero costume with a mismatched too-small cape, hands confidently on hips in a heroic stance, comedic city rooftop background, overconfident expression that looks slightly ridiculous",
      "overridesPose": true,
    },
  ];

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      errorMessage = null;
      resultImage = null;
    }
    notifyListeners();
  }

  void _setAnalyzing(bool value) {
    isAnalyzing = value;
    notifyListeners();
  }

  void clearResults() {
    resultImage = null;
    errorMessage = null;
    isLoading = false;
    _analysisResult = null;
    isAnalyzing = false;
    notifyListeners();
  }


  Future<Map<String, dynamic>?> analyzeImage(File selectedImage) async {
    _setAnalyzing(true);

    try {
      final bytes = await selectedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey');

      final themeNames = surpriseThemes.map((t) => t['name']).join(", ");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                    'You are a professional portrait photographer and stylist. '
                    'Analyze the uploaded photo and describe it precisely so it can '
                    'be recreated with new styling while preserving the subject\'s '
                    'exact pose, framing, and identity. When recommending a theme, '
                        'that will produce the funniest, most shareable, most surprising result — '
                        'every theme in the list is comedic, so pick based on what will look '
                        'most visually funny and shareable for this specific photo.',
              },
            ],
          },
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Analyze this photo and return ONLY JSON in this exact shape:
{
  "gender": "man or woman",
  "pose": "short description of head/body angle and posture",
  "framing": "headshot, half-body, or full-body",
  "lighting": "short description of current lighting direction and quality",
  "hairStyle": "short description of current hair",
  "currentClothingStyle": "short description of current outfit",
  "background": "short description of current background",
  "recommendedTheme": "pick the single funniest and best-fitting theme name from this list: $themeNames"
}''',
                },
                {
                  'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
                },
              ],
            },
          ],
          'generationConfig': {'response_mime_type': 'application/json'},
        }),
      );

      showLog("Analyze response code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse = data['candidates'][0]['content']['parts'][0]['text'];
        final result = jsonDecode(textResponse);

        _analysisResult = result;
        showLog("Analysis successful: $result");
        _setAnalyzing(false);
        return result;
      } else {
        showLog("Analyze API error: ${response.body}");
        _setAnalyzing(false);
        return null; // caller falls back to generic prompt
      }
    } catch (e) {
      showLog("Error in analyzeImage: $e");
      _setAnalyzing(false);
      return null; // fail-soft — generation stage handles null
    }
  }

  Future<void> generateSurpriseImage(File selectedImage, BuildContext context, {Map<String, dynamic>? analysis}) async {
    _setLoading(true);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    try {
      final userBytes = await selectedImage.readAsBytes();
      final userBase64 = base64Encode(userBytes);

      final effectiveAnalysis = analysis ?? _analysisResult;
      final prompt = _buildPrompt(effectiveAnalysis);

      if (prompt.trim().isEmpty) {
        _setLoading(false);
        errorMessage = "Prompt was not ready.";
        showToast("Something went wrong, please try again later");
        return;
      }

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$geminiApiKey');

      showLog("Generation prompt: $prompt");

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
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
          "topK": 32,
         // "imageConfig": {"aspectRatio": "9:16"},
        },
      };

      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(requestBody));


      showLog("Generation response code: ${response.statusCode}");
      showLog("Generation raw body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'] as List;

          final imagePart = parts.cast<Map<String, dynamic>?>().firstWhere((part) => part?.containsKey('inline_data') == true || part?.containsKey('inlineData') == true, orElse: () => null);

          if (imagePart != null) {
            final inlineData = imagePart['inline_data'] ?? imagePart['inlineData'];
            if (inlineData != null && inlineData['data'] != null) {
              final String base64Data = inlineData['data'];

              final file = await _saveImageLocally(base64Data);
              resultImage = file;
              _setLoading(false);

              await coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_gemini_api);

              if (context.mounted && resultImage != null) {
                AppNavigation.NavigationPush(context, VirtualTryOnResultScreen(resultImage: resultImage!));
              }
              showToast("Surprise ready!");
              return;
            }
          }

          _setLoading(false);
          errorMessage = "No image returned by AI.";
          showToast("Something went wrong, please try again later");
        } else {
          _setLoading(false);
          errorMessage = "No response candidates.";
          showToast("Something went wrong, please try again later");
        }
      } else {
        _setLoading(false);
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']['message'] ?? 'Unknown error ${response.statusCode}';
        } catch (_) {
          errorMessage = 'Error ${response.statusCode}: ${response.body}';
        }
        showLog("API Error: $errorMessage");
        showToast("Something went wrong, please try again later");
      }
    } catch (e) {
      showLog("Error in generateSurpriseImage: $e");
      _setLoading(false);
      errorMessage = e.toString();
      showToast("Something went wrong, please try again later");
    }
  }

  Future<void> createSurprise(File selectedImage, BuildContext context) async {
    if (isLoading || isAnalyzing) return;

    final analysis = await analyzeImage(selectedImage);
    if (!context.mounted) return;
    await generateSurpriseImage(selectedImage, context, analysis: analysis);
  }

  String _buildPrompt(Map<String, dynamic>? analysis) {
    final theme = _pickTheme(analysis?['recommendedTheme'] as String?);
    final bool overridesPose = theme['overridesPose'] == true;
    final String themePrompt = theme['prompt'] as String;

    const faceLock = '''CRITICAL RULE: Do NOT change the person's identity. Keep the exact same face — same identity, same facial structure, same skin tone, same eyes, nose, lips, jawline, same age appearance, same facial hair (if any), pixel-accurate to the original bone structure and features. Do not beautify or reshape the face. The facial expression MAY be adjusted to match the comedic theme (e.g. surprised, gleeful, panicked, exaggerated grin) — but the underlying face must still be unmistakably the same person.''';

    String poseLine;
    if (overridesPose || analysis == null) {
      // Either the theme has its own required action pose (riding, falling,
      // floating, etc.) which would conflict with the original static pose,
      // or we have no analysis at all — let the theme define the pose.
      poseLine = "The body pose and positioning should follow the new theme's action naturally, since this is a dynamic comedic scene.";
    } else {
      final pose = (analysis['pose'] as String?)?.trim();
      final framing = (analysis['framing'] as String?)?.trim();
      poseLine = (pose != null && pose.isNotEmpty && framing != null && framing.isNotEmpty)
          ? "Preserve the subject's current pose and framing: $pose, $framing."
          : "Preserve the subject's current pose and framing exactly as in the original photo.";
    }

    return '''Edit this uploaded image into a surprise styled portrait.
 
$faceLock
 
$poseLine
 
Apply this new styling: $themePrompt
 
Match lighting realistically to the new scene while keeping the face itself the same person.
 
Maintain natural skin texture on the face, sharp fine detail, professional comedic-editorial framing.
 
Output an ultra-realistic photo in 4K detail, vertical 9:16 aspect ratio, targeting 1536x2752 resolution, no compression artifacts, no blur, no upscaling artifacts.''';
  }

  Map<String, dynamic> _pickTheme(String? recommendedName) {
    if (recommendedName != null) {
      final match = surpriseThemes.firstWhere((t) => (t['name'] as String?)?.toLowerCase() == recommendedName.toLowerCase(), orElse: () => surpriseThemes[Random().nextInt(surpriseThemes.length)]);
      return match;
    }
    return surpriseThemes[Random().nextInt(surpriseThemes.length)];
  }

  Future<File> _saveImageLocally(String base64String) async {
    try {
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }

      base64String = base64String.replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '').replaceAll('\t', '');

      try {
        base64String = Uri.decodeComponent(base64String);
      } catch (e) {
        showLog("No URL encoding detected");
      }

      if (!_isValidBase64(base64String)) {
        throw Exception("Invalid base64 string format");
      }

      final bytes = base64Decode(base64String);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'surprise_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      final prefs = await SharedPreferences.getInstance();
      final List<String> savedImages = prefs.getStringList('saved_generated_images') ?? [];
      savedImages.insert(0, file.path);

      if (savedImages.length > 50) {
        savedImages.removeRange(50, savedImages.length);
      }

      await prefs.setStringList('saved_generated_images', savedImages);

      showLog("Surprise image saved locally: ${file.path}");
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
