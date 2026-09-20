import 'dart:convert';
import 'dart:io';

import 'package:charmai/ads/AdsVariable.dart';
import 'package:charmai/utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ImageFilterService {
  String kGeminiApiKey = AdsVariable.ca_gemini_api_key;

  String _kGeminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent';

  Future<bool> ImageFilter(File image, [File? image2]) async {
    showLog("start filter");
    try {
      const prompt = '''
            Classify the image for an AI image-generation app.
            
            Return "false" (BLOCK) for:
            - Explicit nudity: exposed breasts/nipples, genitals, or clearly exposed buttocks.
            - Sexual acts or explicit sexual content.
            - Transparent/removed clothing exposing intimate areas.
            - Clearly sexualized intimate-body-part imagery.
            - Non-consensual sexual content, sexual deepfakes, or voyeurism.
            - Graphic gore/violence, terrorism/extremism, or hateful content.
            
            Return "true" (ALLOW) for normal fashion, dating, beach, fitness and lifestyle
            photos when intimate areas are covered. This includes bikinis/swimwear,
            tank tops, crop tops, dresses, mini skirts, shorts, tight clothing,
            cleavage without exposed breasts, bare shoulders/legs/stomach/back,
            kissing, and attractive poses.
            
            Do not judge attractiveness, body shape, clothing length/tightness, or ordinary
            skin exposure. If intimate areas are covered and there is no explicit sexual
            content, ALLOW.
            
            Reply with exactly "true" or "false".
            ''';

      final parts = <Map<String, dynamic>>[
        {'text': prompt},
        {
          'inline_data': {
            'mime_type': _mimeTypeFor(image.path),
            'data': await compute(base64Encode, await image.readAsBytes()),
          },
        },
      ];

      if (image2 != null) {
        parts.add({
          'inline_data': {
            'mime_type': _mimeTypeFor(image2.path),
            'data': await compute(base64Encode, await image2.readAsBytes()),
          },
        });
      }

      final response = await http
          .post(
        Uri.parse('$_kGeminiEndpoint?key=$kGeminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': parts},
          ],
          'generationConfig': {
            'temperature': 0,
            'maxOutputTokens': 10,
            'responseMimeType': 'text/plain',
            'mediaResolution': 'MEDIA_RESOLUTION_LOW',
            'thinkingConfig': {
              'thinkingLevel': 'minimal',
            },
          },
        }),
      ).timeout(const Duration(seconds: 15));

      showLog("this is response from api ${response.body}");

      if (response.statusCode != 200) {
        _showFailureToast();
        return false;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text']
      as String?;

      showLog("this is response from api $text");

      if (text == null) {
        _showFailureToast();
        return false;
      }

      final normalized = text.trim().toLowerCase();
      return normalized.contains('true');
    } catch (e) {
      showLog("this is catch in filter $e");
      _showFailureToast();
      return false; // fail closed
    }
  }

  void _showFailureToast() {
    Fluttertoast.showToast(
      msg: "Something went wrong, please try again",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}