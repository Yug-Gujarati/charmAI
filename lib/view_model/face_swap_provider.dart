import 'dart:convert';
import 'dart:io';

import 'package:charmai/utils/navigation.dart';
import 'package:charmai/utils/loading_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;

import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/appOpenAdManager.dart';
import '../services/image_filter_service.dart';
import '../utils/app_constants.dart';
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class FaceSwapProvider extends ChangeNotifier {
  bool isLoading = false;
  String? taskId;
  String? resultImageUrl;
  String? errorMessage;

  File? _targetImage;

  File? _resultImage;
  File? get resultImage => _resultImage;

  File? get targetImage => _targetImage;

  final ImagePicker _picker = ImagePicker();
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  static const String baseUrl = 'https://www.ailabapi.com';
  static String aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String apiKeyField = 'ailabapi-api-key';

  bool isViolatingImage = false;
  final ImageFilterService _imageFilterService = ImageFilterService();

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      loadingScreen.show();
    } else {
      loadingScreen.hide();
    }
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<bool> _isImageSafe(File image, [File? image2]) async {
    final isSafe = await _imageFilterService.ImageFilter(image, image2);
    if (!isSafe) {
      showLog("Image(s) rejected by content filter.");
    }
    return isSafe;
  }

  void clearResults() {
    showLog("clear result");
    taskId = null;
    resultImageUrl = null;
    errorMessage = null;
    _targetImage = null;
    notifyListeners();
  }

  // ─── Pick Target Image (user's face) ─────────────────────────
  Future<bool> pickTargetImage() async {
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);

    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final croppedFile = await _cropImage(File(image.path));

        if (croppedFile != null) {
          _targetImage = croppedFile;
          resultImageUrl = null;
          notifyListeners();

          _appLifecycleReactor = AppLifecycleReactor(
            appOpenAdManager: appOpenAdManager,
          );
          _appLifecycleReactor.listenToAppStateChanges(shouldShow: true);
          return true;
        }
      }

      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: appOpenAdManager,
      );
      _appLifecycleReactor.listenToAppStateChanges(shouldShow: true);
      return false;
    } catch (e) {
      showLog('Error picking image: $e');
      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: appOpenAdManager,
      );
      _appLifecycleReactor.listenToAppStateChanges(shouldShow: true);
      return false;
    }
  }

  // ─── Crop Image ───────────────────────────────────────────────
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxWidth: 4096,
        maxHeight: 4096,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      showLog('Error cropping image: $e');
      return null;
    }
  }

  // ─── Get template image from Cache & Convert to JPG if needed ───
  Future<File?> _getTemplateFile(String imageUrl) async {
    try {
      showLog("Checking cache for template: $imageUrl");
      final File cachedFile = await DefaultCacheManager().getSingleFile(imageUrl);

      // Check if the file is WebP (AILabAPI doesn't support WebP)
      if (cachedFile.path.toLowerCase().endsWith('.webp')) {
        showLog("WebP detected. Converting to JPG for API compatibility...");

        final bytes = await cachedFile.readAsBytes();
       // final image = img.decodeImage(bytes);
        final jpgBytes = await compute(convertWebpToJpg, bytes);

        if (jpgBytes != null) {
          //final jpgBytes = img.encodeJpg(jpgBytes, quality: 90);
          final tempDir = await getTemporaryDirectory();
          final jpgPath = '${tempDir.path}/temp_template_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final jpgFile = File(jpgPath);
          await jpgFile.writeAsBytes(jpgBytes);

          showLog("Conversion complete: $jpgPath");
          return jpgFile;
        }
      }

      showLog("Template file ready: ${cachedFile.path}");
      return cachedFile;
    } catch (e) {
      showLog("Error fetching/converting template: $e");
      return null;
    }
  }

  // ─── Generate: Download template + Call API ──────────────────
  Future<bool> generateImage(
      BuildContext context, String templateUrl) async {
    showLog("this is image url $templateUrl");
    if (_targetImage == null) {
      _setError("Please select your face image.");
      showToast("Please select your face image.");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Step 1: Get template from local cache (Instant & Free)
      final File? templateFile = await _getTemplateFile(templateUrl);

      if (templateFile == null) {
        _setError("Failed to load template image.");
        _setLoading(false);
        return false;
      }

      // Step 2: Call face swap API
      return await _callFaceSwapApi(templateFile, _targetImage!,  context);
    } catch (e) {
      showLog("Error in generateImage: $e");
      _setError("Something went wrong: $e");
      _setLoading(false);
      return false;
    }
  }

  // ─── API Call ─────────────────────────────────────────────────
  Future<bool> _callFaceSwapApi(
      File targetImage, File templateFile, BuildContext context) async {

    bool isSafe = await _isImageSafe(targetImage);
    if (!isSafe) {
      _setLoading(false);
      showLog("One or more image violate");
      showToast("Images violate our content policy, please try with other image.");
      return false;
    }

    try {
      showLog("this is target image $targetImage");
      showLog("this is template file $templateFile");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/portrait/editing/ai-face-swap'),
      );

      request.headers[apiKeyField] = aiLabApiKey;


      request.files.add(
        await http.MultipartFile.fromPath(
          'image_target',
          targetImage.path,
          filename: 'target.jpg',
        ),
      );


      request.files.add(
        await http.MultipartFile.fromPath(
          'image_template',
          templateFile.path,
          filename: 'template.jpg',
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      showLog("Face Swap API Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['error_code'] == 0) {

          taskId = jsonResponse['task_id'];
          showLog("Task ID received: $taskId");

          if (taskId != null && taskId!.isNotEmpty) {
            _setLoading(false);
            notifyListeners();
            await pollTaskResult(context: context);
            return true;
          } else {
            showToast("Something went wrong, please try again");
            _setError('No result or task ID received');
            _setLoading(false);
            return false;
          }
        } else {
          showToast("Something went wrong, please try again");
          _setError(jsonResponse['error_msg'] ?? 'Unknown error occurred');
          _setLoading(false);
          return false;
        }
      } else {
        showToast("Something went wrong, please try again");
        _setError('Server error: ${response.statusCode}');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      showToast("Something went wrong, please try again");
      _setError('Network error: ${e.toString()}');
      showLog("API call error: $e");
      _setLoading(false);
      return false;
    }
  }

  // ─── Poll Task Result ─────────────────────────────────────────
  Future<bool> pollTaskResult({
    int maxAttempts = 100,
    int delaySeconds = 2,
    required BuildContext context,
  }) async {
    showLog("Start polling result");
    if (taskId == null) {
      _setError('No task ID available');
      return false;
    }

    _setLoading(true);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await Future.delayed(Duration(seconds: delaySeconds));

        var response = await http.get(
          Uri.parse(
            '$baseUrl/api/common/query-async-task-result?task_id=$taskId',
          ),
          headers: {apiKeyField: aiLabApiKey},
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          showLog("response of task polling $jsonResponse");

          if (jsonResponse['error_code'] == 0) {
            var taskStatus = jsonResponse['task_status'];
            var data = jsonResponse['data'];

            showLog("task_status value: $taskStatus");

            if (taskStatus == 2) {
              // ✅ Primary path: result_urls is a list
              final resultUrls = data?['result_urls'];

              if (resultUrls != null &&
                  resultUrls is List &&
                  resultUrls.isNotEmpty) {
                resultImageUrl = resultUrls[0];
                showLog(
                    "Successfully got result image from result_urls: $resultImageUrl");
              }
              // Fallback paths
              else if (data?['images'] != null && data['images'].isNotEmpty) {
                resultImageUrl = data['images'][0];
                showLog(
                    "Successfully got result image from images: $resultImageUrl");
              } else {
                resultImageUrl = data?['image'] ?? data?['image'];
                showLog(
                    "Successfully got result image from fallback: $resultImageUrl");
              }

              if (resultImageUrl != null) {
                showLog("Navigating to result screen");
                // final coinProvider =
                // Provider.of<CoinProvider>(context, listen: false);
                // coinProvider
                //     .decrementCoins(AdsVariable.ca_reduce_coin_on_hair_style);
                // _setLoading(false);
                // notifyListeners();
                // _saveImageLocally(resultImageUrl!);
                // AppNavigation.NavigationPush(
                //     context, ResultScreen(imageUrl: resultImageUrl!));

                _resultImage = await _saveImageLocally(resultImageUrl!);

                // Deduct coins
                await coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_ai_lab_api);

                _setLoading(false);

                // Navigate to result screen
                if (context.mounted && _resultImage != null) {
                  AppNavigation.NavigationPush(
                    context,
                    VirtualTryOnResultScreen(resultImage: _resultImage!),
                  );
                }
                return true;
              }

              // Nothing found
              _setError('Result image not found in response');
              _setLoading(false);
              showToast("Something went wrong, please try again");
              return false;
            } else if (taskStatus == 3) {
              _setError('Task failed: ${data?['error'] ?? 'Unknown error'}');
              showToast("Something went wrong, please try again");
              _setLoading(false);
              return false;
            } else if (taskStatus == 1) {
              showLog(
                  "Task still processing, attempt ${attempt + 1}/$maxAttempts");
              continue;
            }
          } else {
            showToast("Something went wrong, please try again");
            _setError(jsonResponse['error_msg'] ?? 'Query error');
            _setLoading(false);
            return false;
          }
        } else {
          final errMsg = parseApiErrorMessage(response.body);
          showToast(errMsg);
          _setError(errMsg);
          showLog('Server error: ${response.statusCode} | ${response.body}');
          _setLoading(false);
          return false;
        }
      } catch (e) {
        showToast("Something went wrong, please try again");
        _setError('Network error: ${e.toString()}');
        showLog('Server error: ${e.toString()}');
        _setLoading(false);
        return false;
      }
    }

    showToast("Something went wrong, please try again");
    _setError('Task timeout - please try again');
    _setLoading(false);
    return false;
  }





  Future<File?> _saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'charm_ai${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      return null;
    } catch (e) {
      showLog("Error saving image: $e");
      return null;
    }
  }

}

// This function MUST be completely outside the class!
// Isolates cannot serialize the FaceSwapProvider class to run it.
List<int>? convertWebpToJpg(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image != null) {
    return img.encodeJpg(image, quality: 90);
  }
  return null;
}
