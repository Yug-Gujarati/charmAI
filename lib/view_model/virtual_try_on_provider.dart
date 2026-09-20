import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/appOpenAdManager.dart';
import '../services/image_filter_service.dart';
import '../utils/app_constants.dart';
import '../utils/navigation.dart';
import '../utils/loading_screen.dart';
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class VirtualTryOnProvider extends ChangeNotifier {
  bool isLoading = false;
  static const String _baseUrl = 'https://www.ailabapi.com';
  static String _aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String _apiKeyHeader = 'ailabapi-api-key';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _resultImageUrl;
  String? get resultImageUrl => _resultImageUrl;

  File? _resultImage;
  File? get resultImage => _resultImage;

  File? _clothSelectImage;
  final ImagePicker _picker = ImagePicker();

  String? _taskId;


  String _clothesType = 'upper_body';
  String get clothesType => _clothesType;

  File? get clothSelectImage => _clothSelectImage;
  bool isViolatingImage = false;
  final ImageFilterService _imageFilterService = ImageFilterService();

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      _errorMessage = null;
      _resultImageUrl = null;
      _resultImage = null;
      loadingScreen.show();
    } else {
      loadingScreen.hide();
    }
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearResults() {
    _resultImage = null;
    _resultImageUrl = null;
    _clothSelectImage = null;
    _errorMessage = null;
    _taskId = null;
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

  void setClothesType(String type) {
    _clothesType = type;
    notifyListeners();
  }

  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;


  Future<bool> pickImage() async {

    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);

    try {

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final croppedFile = await _cropImage(File(image.path));

        if (croppedFile != null) {
          _clothSelectImage = croppedFile;
          notifyListeners();
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

  void _handleError(String message) {
    _setLoading(false);
    _setError(message);
    showLog("Error: $message");
    Fluttertoast.showToast(msg: message);
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

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      showLog('Error cropping image: $e');
      return null;
    }
  }


  Future<void> virtualTryOn(
      File userImage,
      File clothImage,
      BuildContext context,
      ) async {
    _setLoading(true);

    bool isSafe = await _isImageSafe(userImage, clothImage);

    if (!isSafe) {
      _setLoading(false);
      showLog("One or more image violate");
      showToast("Images violate our content policy, please try with other image.");
      return;
    }


    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/portrait/editing/try-on-clothes'),
      );

      request.headers[_apiKeyHeader] = _aiLabApiKey;

      request.fields['task_type'] = 'async';
      request.fields['clothes_type'] = _clothesType; // set by user

      request.files.add(
        await http.MultipartFile.fromPath('person_image', userImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('clothes_image', clothImage.path),
      );

      showLog("Submitting try-on job | clothes_type=$_clothesType");

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      showLog("Submit status: ${response.statusCode}");
      showLog("Submit body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['error_code'] == 0) {
          _taskId = json['task_id'] as String?;

          if (_taskId != null && _taskId!.isNotEmpty) {
            showLog("Task ID received: $_taskId");
            _setLoading(false);
            await _pollTaskResult(context: context);
          } else {
            showLog("No task_id in response");
            _handleError("No task ID returned. Please try again.");
          }
        } else {
          _handleError(parseApiErrorMessage(response.body));
        }
      } else {
        _handleError(parseApiErrorMessage(response.body));
      }
    } catch (e) {
      showLog("Exception in virtualTryOn: $e");
      _handleError(e.toString());
    }
  }


  Future<bool> _pollTaskResult({
    int maxAttempts = 100,
    int delaySeconds = 2,
    required BuildContext context,
  }) async {
    if (_taskId == null) {
      _handleError('No task ID available');
      return false;
    }

    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    _setLoading(true);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await Future.delayed(Duration(seconds: delaySeconds));

        final response = await http.get(
          Uri.parse('$_baseUrl/api/common/query-async-task-result?task_id=$_taskId'),
          headers: {_apiKeyHeader: _aiLabApiKey},
        );

        showLog("Poll attempt ${attempt + 1} | status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          showLog("Poll response: $json");

          if (json['error_code'] == 0) {
            final taskStatus = json['task_status'] as int?;
            final data = json['data'] as Map<String, dynamic>?;

            showLog("task_status: $taskStatus");

            if (taskStatus == 2) {

              String? imageUrl = data?['image'] as String?;

              // Fallback paths
              imageUrl ??=
              (data?['images'] as List?)?.isNotEmpty == true
                  ? data!['images'][0] as String?
                  : null;

              imageUrl ??=
                  data?['result']?['image_url'] as String? ??
                      data?['image_url'] as String? ??
                      data?['output_image_url'] as String?;

              if (imageUrl != null) {
                _resultImageUrl = imageUrl;
                showLog("Result image URL: $imageUrl");

                // Save locally
                _resultImage = await _saveImageLocally(imageUrl);

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

                Fluttertoast.showToast(msg: "Try-on successful!");
                return true;
              } else {
                _handleError("Result image not found in response.");
                return false;
              }
            }

            else if (taskStatus == 3) {
              // ── Failed ──
              _handleError('Task failed: ${data?['error'] ?? 'Unknown error'}');
              return false;
            } else if (taskStatus == 1) {
              // ── Still processing ──
              showLog("Still processing… attempt ${attempt + 1}/$maxAttempts");
              continue;
            }
          } else {
            _handleError(parseApiErrorMessage(response.body));
            return false;
          }
        } else {
          _handleError(parseApiErrorMessage(response.body));
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



  Future<File?> _saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'tryon_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
