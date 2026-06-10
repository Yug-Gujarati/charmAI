import 'dart:convert';
import 'dart:io';

import 'package:charmai/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/appOpenAdManager.dart';
import '../utils/app_constants.dart';
import '../utils/app_constants.dart' as Fluttertoast;
import '../view/virtual_try_on_result_screen.dart';
import 'coin_managment.dart';

class ImageGenerationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? taskId;
  String? resultImageUrl;
  String? errorMessage;

  // ─── Two separate images ──────────────────────────────────────
  File? _boyImage;
  File? _girlImage;
  File? _mergedImage;

  File? _resultImage;
  File? get resultImage => _resultImage;

  File? get boyImage => _boyImage;

  File? get girlImage => _girlImage;

  File? get mergedImage => _mergedImage;

  final ImagePicker _picker = ImagePicker();
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  static const String baseUrl = 'https://www.ailabapi.com';
  static String aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String apiKeyField = 'ailabapi-api-key';


  // ─── Helpers ──────────────────────────────────────────────────
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearResults() {
    showLog("clear result");
    taskId = null;
    resultImageUrl = null;
    errorMessage = null;
    _boyImage = null;
    _girlImage = null;
    _mergedImage = null;
    notifyListeners();
  }

  // ─── Pick Boy Image ───────────────────────────────────────────
  Future<bool> pickBoyImage() async {
    return await _pickAndCrop(isBoy: true);
  }

  // ─── Pick Girl Image ──────────────────────────────────────────
  Future<bool> pickGirlImage() async {
    return await _pickAndCrop(isBoy: false);
  }

  // ─── Internal: Pick + Crop ────────────────────────────────────
  Future<bool> _pickAndCrop({required bool isBoy}) async {
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
          if (isBoy) {
            _boyImage = croppedFile;
          } else {
            _girlImage = croppedFile;
          }


          _mergedImage = null;
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
      debugPrint('Error picking image: $e');
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
        maxHeight: 2000,
        maxWidth: 2000,
        uiSettings: [

          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,

            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
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
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  // ─── Merge Boy + Girl Side by Side ───────────────────────────
  Future<File?> _mergeImages(File boyFile, File girlFile) async {
    try {
      final img.Image? boyImg = img.decodeImage(await boyFile.readAsBytes());
      final img.Image? girlImg = img.decodeImage(await girlFile.readAsBytes());

      if (boyImg == null || girlImg == null) {
        showLog("Failed to decode one or both images");
        return null;
      }

      // Resize both to same height keeping aspect ratio
      const int targetHeight = 2000;

      final img.Image resizedBoy = img.copyResize(
        boyImg,
        height: targetHeight,
        width: (boyImg.width * targetHeight / boyImg.height).round(),
      );

      final img.Image resizedGirl = img.copyResize(
        girlImg,
        height: targetHeight,
        width: (girlImg.width * targetHeight / girlImg.height).round(),
      );

      // Create canvas for side-by-side merge
      final int totalWidth = resizedBoy.width + resizedGirl.width;
      final img.Image merged = img.Image(width: totalWidth, height: targetHeight);

      // Fill background black
      img.fill(merged, color: img.ColorRgb8(0, 0, 0));

      // Boy on left, girl on right
      img.compositeImage(merged, resizedBoy, dstX: 0, dstY: 0);
      img.compositeImage(merged, resizedGirl, dstX: resizedBoy.width, dstY: 0);

      // ─── Final Safety Resize (API limit: 4096x4096) ───────────
      img.Image finalImage = merged;

      if (merged.width > 4096 || merged.height > 4096) {
        double scaleW = 4096 / merged.width;
        double scaleH = 4096 / merged.height;
        double scale = scaleW < scaleH ? scaleW : scaleH;

        finalImage = img.copyResize(
          merged,
          width: (merged.width * scale).round(),
          height: (merged.height * scale).round(),
        );
        //showLog("Resized merged image to fit API limit: ${finalImage.width}x${finalImage.height}");
      } else {
        //showLog("Merged image within API limit: ${merged.width}x${merged.height}");
      }

      // Save to temp directory
      final Directory tempDir = await getTemporaryDirectory();
      final String mergedPath =
          '${tempDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File mergedFile = File(mergedPath);
      await mergedFile.writeAsBytes(img.encodeJpg(finalImage, quality: 90));

      // ─── File Size Check (API limit: 10MB) ────────────────────
      final fileSize = await mergedFile.length();
      showLog("Merged image size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

      showLog("Merged image saved at: $mergedPath");
      return mergedFile;
    } catch (e) {
      showLog("Error merging images: $e");
      return null;
    }
  }

  // ─── Generate: Merge then Call API ───────────────────────────
  Future<bool> generateImage(BuildContext context, String prompt) async {
    if (_boyImage == null || _girlImage == null) {
      _setError("Please select both images.");
     showToast("Please select both images.");
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Step 1: Merge images
      final File? merged = await _mergeImages(_boyImage!, _girlImage!);
      showLog("this is image $merged");
      if (merged == null) {
        _setError("Failed to merge images.");
        _setLoading(false);
        return false;
      }

      _mergedImage = merged;
      notifyListeners();

      // Step 2: Call API with merged image
      return await _callGenerateImageApi(merged, context, prompt);
    } catch (e) {
      showLog("Error in generateFaceSwap: $e");
      _setError("Something went wrong: $e");
      _setLoading(false);
      return false;
    }
  }

  // ─── API Call ─────────────────────────────────────────────────
  Future<bool> _callGenerateImageApi(File mergedImage, BuildContext context, String prompt) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/image/effects/ai-photography'),
      );

      request.headers[apiKeyField] = aiLabApiKey;

      request.fields['style_title'] = 'Couple';
      request.fields['style_desc'] = prompt;
      request.fields['image_size'] = '9:16';
      request.fields['task_type'] = 'async';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          mergedImage.path,
          filename: 'merged_image.jpg',
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      showLog("API Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['error_code'] == 0) {
          taskId = jsonResponse['task_id'];
          showLog("Task ID received: $taskId");

          if (taskId != null && taskId!.isNotEmpty) {
            _setLoading(false);
            notifyListeners();

            // Start polling — same logic as hairstyle
            await pollTaskResult(context: context);
            return true;
          } else {
            showToast("Something went wrong, please try again");
            _setError('Task ID not received from server');
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

  // ─── Poll Task Result (unchanged from your original) ─────────
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
              final resultUrls = data?['result_urls'];

              if (resultUrls != null && resultUrls is List && resultUrls.isNotEmpty) {
                resultImageUrl = resultUrls[0];
                showLog("Successfully got result image from result_urls: $resultImageUrl");
              }
              // Fallback paths
              else if (data?['images'] != null && data['images'].isNotEmpty) {
                resultImageUrl = data['images'][0];
                showLog("Successfully got result image from images: $resultImageUrl");
              } else {
                resultImageUrl = data?['image_url'] ?? data?['output_image_url'];
                showLog("Successfully got result image from fallback: $resultImageUrl");
              }

              if (resultImageUrl != null) {
                showLog("this is result image");
                // final coinProvider = Provider.of<CoinProvider>(context, listen: false);
                // coinProvider.decrementCoins(AdsVariable.ca_reduce_coin_on_hair_style);
               // _setLoading(false);
               //  _saveImageLocally(resultImageUrl!);
               //  showLog("after image succefully saved");
               //  AppNavigation.NavigationPush(context, ResultScreen(imageUrl: resultImageUrl!));
                _resultImage = await _saveImageLocally(resultImageUrl!);

                if (context.mounted) {
                  Provider.of<CoinProvider>(context, listen: false)
                      .decrementCoins(AdsVariable.ca_reduce_coin_on_ai_lab_api);
                }

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
          showToast("Something went wrong, please try again");
          _setError('Server error: ${response.statusCode}');
          _setLoading(false);
          return false;
        }
      } catch (e) {
        showToast("Something went wrong, please try again");
        _setError('Network error: ${e.toString()}');
        _setLoading(false);
        return false;
      }
    }

    showToast("Something went wrong, please try again");
    _setError('Task timeout - please try again');
    _setLoading(false);
    return false;
  }

  // // ─── Save Image Locally (unchanged) ──────────────────────────
  // Future<void> _saveImageLocally(String imageUrl) async {
  //   try {
  //     final response = await http.get(Uri.parse(imageUrl));
  //     if (response.statusCode == 200) {
  //       final directory = await getApplicationDocumentsDirectory();
  //       final fileName =
  //           'charm_ai${DateTime
  //           .now()
  //           .millisecondsSinceEpoch}.jpg';
  //       final file = File('${directory.path}/$fileName');
  //       await file.writeAsBytes(response.bodyBytes);
  //
  //       final prefs = await SharedPreferences.getInstance();
  //       final List<String> savedImages =
  //           prefs.getStringList('saved_generated_images') ?? [];
  //       savedImages.add(file.path);
  //       await prefs.setStringList('saved_generated_images', savedImages);
  //
  //       showLog("Image saved locally: ${file.path}");
  //     }
  //   } catch (e) {
  //     showLog("Error saving image: $e");
  //   }
  // }
  //


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



//6e64ff07c4462faf8605ece3d9ce721a
//https://ai-result-rapidapi.ailabtools.com/image/photography/2026-04-10/191234-c53ad27e-5e0b-4a1b-fb68-c0eb479ec3ee-1775819554.png