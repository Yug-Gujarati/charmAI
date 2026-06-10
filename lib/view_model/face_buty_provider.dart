import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../utils/app_constants.dart';

class FaceBeautyProvider extends ChangeNotifier {
  bool isLoading = false;

  // ── AILab API config ──
  static const String _baseUrl = 'https://www.ailabapi.com';
  static String _aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String _apiKeyHeader = 'ailabapi-api-key';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _resultImage;
  File? get resultImage => _resultImage;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;


  double _retouchDegree = 1.5;
  double _whiteningDegree = 1.5;

  double get retouchDegree => _retouchDegree;
  double get whiteningDegree => _whiteningDegree;

  void setRetouchDegree(double value) {
    _retouchDegree = value;
    notifyListeners();
  }

  void setWhiteningDegree(double value) {
    _whiteningDegree = value;
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    _resultImage = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  //  Internal helpers
  // ─────────────────────────────────────────

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      _errorMessage = null;
      _resultImage = null;
    }
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearResults() {
    _resultImage = null;
    _selectedImage = null;
    _errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  void _handleError(String message) {
    _setLoading(false);
    _setError(message);
    showLog("Error: $message");
    Fluttertoast.showToast(msg: message);
  }

  // ─────────────────────────────────────────
  //  Main API call  (SYNC — no task_id)
  // ─────────────────────────────────────────

  Future<void> applyFaceBeauty(
      File image,
      BuildContext context,
      ) async {
    _setLoading(true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/portrait/effects/smart-skin'),
      );

      request.headers[_apiKeyHeader] = _aiLabApiKey;

      // ── Body fields ──
      // API expects float string in range [0, 1.5]; NO task_type field
      request.fields['retouch_degree'] = _retouchDegree.toStringAsFixed(2);
      request.fields['whitening_degree'] = _whiteningDegree.toStringAsFixed(2);

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      showLog(
        "Submitting smart-skin job | "
            "retouch=$_retouchDegree | whitening=$_whiteningDegree",
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      showLog("Response status : ${response.statusCode}");
      showLog("Response body   : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

        // ── 1. Check public response fields ──
        final int errorCode = json['error_code'] as int? ?? -1;

        if (errorCode == 0) {
          // ── 2. Parse business response fields ──
          final data = json['data'] as Map<String, dynamic>?;
          final String? imageUrl = data?['image_url'] as String?;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            showLog("Result image URL: $imageUrl");

            final File? saved = await _saveImageLocally(imageUrl);

            if (saved != null) {
              _resultImage = saved;
              _setLoading(false);
              Fluttertoast.showToast(msg: "Face beauty applied successfully!");
            } else {
              _handleError("Failed to download result image. Please try again.");
            }
          } else {
            _handleError("Result image URL is empty. Please try again.");
          }
        } else {
          // Surface the API error message to the user
          final String apiError =
              json['error_msg']?.toString() ??
                  json['error_detail']?['message']?.toString() ??
                  'Unknown API error (code: $errorCode)';
          _handleError(apiError);
        }
      } else {
        _handleError('Server error: ${response.statusCode}. Please try again.');
      }
    } catch (e, stackTrace) {
      showLog("Exception in applyFaceBeauty: $e\n$stackTrace");
      _handleError("Something went wrong. Please try again.");
    }
  }

  // ─────────────────────────────────────────
  //  Download & persist result image
  // ─────────────────────────────────────────

  Future<File?> _saveImageLocally(String imageUrl) async {
    try {
      showLog("Downloading result image from: $imageUrl");

      final http.Response response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName =
            'facebeauty_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        // Persist path in SharedPreferences (keep last 50)
        final prefs = await SharedPreferences.getInstance();
        final List<String> saved =
            prefs.getStringList('saved_generated_images') ?? [];
        saved.insert(0, file.path);
        if (saved.length > 50) saved.removeRange(50, saved.length);
        await prefs.setStringList('saved_generated_images', saved);

        showLog("Image saved locally: ${file.path}");
        return file;
      } else {
        showLog("Download failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      showLog("Error downloading/saving image: $e");
      return null;
    }
  }
}