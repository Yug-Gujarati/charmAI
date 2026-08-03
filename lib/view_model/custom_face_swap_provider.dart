import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/appOpenAdManager.dart';
import '../utils/app_constants.dart';
import '../utils/navigation.dart';
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class CustomFaceSwapProvider extends ChangeNotifier {
  bool isLoading = false;

  static const String _baseUrl = 'https://www.ailabapi.com';
  static String _aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String _apiKeyHeader = 'ailabapi-api-key';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _resultImage;
  File? get resultImage => _resultImage;


  File? _targetImage;
  File? get targetImage => _targetImage;

  String? _taskId;

  final ImagePicker _picker = ImagePicker();
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

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
    _targetImage = null;
    _errorMessage = null;
    _taskId = null;
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
  //  Image picking — target (user face)
  // ─────────────────────────────────────────

  Future<bool> pickTargetImage() async {
    _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final croppedFile = await _cropImage(File(image.path));
        if (croppedFile != null) {
          _targetImage = croppedFile;
          notifyListeners();
          return true;
        }
      }

      _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor.listenToAppStateChanges(shouldShow: true);
      return false;
    } catch (e) {
      showLog('Error picking target image: $e');
      _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor.listenToAppStateChanges(shouldShow: true);
      return false;
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxHeight: 4096,
        maxWidth: 4096,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,

            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,

            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      showLog('Error cropping image: $e');
      return null;
    }
  }


  Future<void> applyFaceSwap(
      File targetImage,
      File templateImage,
      BuildContext context,
      ) async {
    _setLoading(true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/portrait/editing/ai-face-swap'),
      );

      request.headers[_apiKeyHeader] = _aiLabApiKey;

      // No task_type field — API defaults to async
      request.files.add(
        await http.MultipartFile.fromPath('image_target', targetImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image_template', templateImage.path),
      );

      showLog("Submitting face swap job");

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      showLog("Submit status: ${response.statusCode}");
      showLog("Submit body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonBody['error_code'] == 0) {
          _taskId = jsonBody['task_id'] as String?;

          if (_taskId != null && _taskId!.isNotEmpty) {
            showLog("Task ID received: $_taskId");
            _setLoading(false);
            await _pollTaskResult(context: context);
          } else {
            _handleError("No task ID returned. Please try again.");
          }
        } else {
          _handleError(jsonBody['error_msg']?.toString() ?? 'Unknown error');
        }
      } else {
        _handleError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showLog("Exception in applyFaceSwap: $e");
      _handleError(e.toString());
    }
  }

  // ─────────────────────────────────────────
  //  STEP 2 — Poll until result is ready
  // ─────────────────────────────────────────

  Future<bool> _pollTaskResult({
    int maxAttempts = 100,
    int delaySeconds = 2,
    required BuildContext context,
  }) async {
    if (_taskId == null) {
      _handleError('No task ID available');
      return false;
    }

    _setLoading(true);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await Future.delayed(Duration(seconds: delaySeconds));

        final response = await http.get(
          Uri.parse('$_baseUrl/api/common/query-async-task-result?task_id=$_taskId'),
          headers: {_apiKeyHeader: _aiLabApiKey},
        );

        showLog("Poll attempt ${attempt + 1} | status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
          showLog("Poll response: $jsonBody");

          if (jsonBody['error_code'] == 0) {
            final taskStatus = jsonBody['task_status'] as int?;
            final data = jsonBody['data'] as Map<String, dynamic>?;

            showLog("task_status: $taskStatus");

            if (taskStatus == 2) {
              // ── Success ──
              // Try all known response image field patterns
              String? imageUrl = data?['image'] as String?;

              imageUrl ??= data?['image_url'] as String?;

              imageUrl ??=
              (data?['images'] as List?)?.isNotEmpty == true
                  ? data!['images'][0] as String?
                  : null;

              imageUrl ??=
                  data?['result']?['image_url'] as String? ??
                      data?['output_image_url'] as String?;

              if (imageUrl != null) {
                showLog("Result image URL: $imageUrl");

                _resultImage = await _saveImageLocally(imageUrl);

                await coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_ai_lab_api);

                _setLoading(false);

                if (context.mounted && _resultImage != null) {
                  AppNavigation.NavigationPush(
                    context,
                    VirtualTryOnResultScreen(resultImage: _resultImage!),
                  );
                }

                Fluttertoast.showToast(msg: "Face swap successful!");
                return true;
              } else {
                _handleError("Result image not found in response.");
                return false;
              }
            } else if (taskStatus == 3) {
              // ── Failed ──
              _handleError('Task failed: ${data?['error'] ?? 'Unknown error'}');
              return false;
            } else if (taskStatus == 1) {
              // ── Still processing ──
              showLog("Still processing… attempt ${attempt + 1}/$maxAttempts");
              continue;
            }
          } else {
            _handleError(jsonBody['error_msg']?.toString() ?? 'Query error');
            return false;
          }
        } else {
          _handleError('Server error: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        showLog("Poll exception: $e");
        _handleError('Network error: $e');
        return false;
      }
    }

    _handleError('Request timed out. Please try again.');
    return false;
  }

  // ─────────────────────────────────────────
  //  Save result image locally
  // ─────────────────────────────────────────

  Future<File?> _saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'faceswap_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        final prefs = await SharedPreferences.getInstance();
        final List<String> savedImages =
            prefs.getStringList('saved_generated_images') ?? [];
        savedImages.insert(0, file.path);
        if (savedImages.length > 50) savedImages.removeRange(50, savedImages.length);
        await prefs.setStringList('saved_generated_images', savedImages);

        showLog("Image saved locally: ${file.path}");
        return file;
      }

      showLog("Failed to download image: ${response.statusCode}");
      return null;
    } catch (e) {
      showLog("Error saving image: $e");
      return null;
    }
  }
}