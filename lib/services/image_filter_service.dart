import 'dart:convert';
import 'dart:io';

import 'package:charmai/ads/AdsVariable.dart';
import 'package:http/http.dart' as http;

class ImageFilterService {

   String kGeminiApiKey = AdsVariable.ca_gemini_api_key;

   String _kGeminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<bool> ImageFilter(File image, [File? image2]) async {
    try {
      const prompt = '''
You are a content moderation classifier. Look at the image(s) and decide if
it contains ANY of the following:
- Nudity or sexual content: count this if a person is nude, or if their
  chest/torso, groin, or buttocks are exposed or covered only by
  something as minimal as a bikini, underwear, or lingerie, or if the
  pose itself is sexually suggestive. Judge this by how much skin is
  actually exposed on the torso and groin/buttocks area — NOT by
  garment length, fit, or category. A short or bodycon/fitted mini
  dress, mini skirt, or shorts that fully covers the chest, torso, and
  back down to at least mid-thigh is ORDINARY FASHION CLOTHING and must
  NOT be counted as nudity, no matter how short, tight, or low-cut the
  neckline is, as long as the chest itself is not exposed. Do NOT count
  kissing or ordinary affectionate contact as nudity by itself, and do
  not count normal, fully-covering everyday or fashion clothing (e.g.
  t-shirts, dresses, mini dresses, skirts, shorts, party wear, jeans) as
  nudity just because it is short, tight, sleeveless, or stylish.
- Violence: depictions of physical violence, weapons used to harm, gore,
  or injury.
- Harassment or impersonation: content designed to harass, bully, or
  impersonate a real person without consent.
- Hate: hate symbols, hateful slogans, or content demeaning a group
  based on race, religion, ethnicity, gender, or similar.
- Terrorism: content promoting or depicting terrorist acts, extremist
  symbols, or violent extremism.
 
Respond with EXACTLY one word and nothing else: "false" if the image
contains any of the above, or "true" if it contains none of them. Do not
add punctuation, explanation, or any other text.
''';

      final parts = <Map<String, dynamic>>[
        {'text': prompt},
        {
          'inline_data': {
            'mime_type': _mimeTypeFor(image.path),
            'data': base64Encode(await image.readAsBytes()),
          },
        },
      ];

      if (image2 != null) {
        parts.add({
          'inline_data': {
            'mime_type': _mimeTypeFor(image2.path),
            'data': base64Encode(await image2.readAsBytes()),
          },
        });
      }

      final response = await http.post(
        Uri.parse('$_kGeminiEndpoint?key=$kGeminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': parts,
            },
          ],
          'generationConfig': {
            'temperature': 0,
            'maxOutputTokens': 5,
          },
        }),
      );

      if (response.statusCode != 200) {
        return false; // fail closed
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text']
      as String?;

      if (text == null) return false;

      final normalized = text.trim().toLowerCase();
      return normalized == 'true';
    } catch (_) {
      return false;
    }
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}