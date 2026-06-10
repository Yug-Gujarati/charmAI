import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/AdsVariable.dart';
import '../utils/app_constants.dart';
import '../utils/hairstyle_data.dart';
import 'coin_managment.dart';

class HairStyleChangerProvider extends ChangeNotifier {
  bool isLoading = false;
  String? taskId;
  String? resultImageUrl;
  String? errorMessage;

  bool isFemale = false;
  String selectedHairStyle = 'BuzzCut';
  String selectedHairColor = 'blonde';

  Map<String, String> get currentHairstyles =>
      isFemale ? HairstyleData.femaleHairstyles : HairstyleData.maleHairstyles;

  void setGender(bool value) {
    isFemale = value;
    // Reset selection to first item of the new list to avoid invalid state
    selectedHairStyle = currentHairstyles.keys.first;
    notifyListeners();
  }

  void setHairStyle(String style) {
    selectedHairStyle = style;
    notifyListeners();
  }

  void setHairColor(String color) {
    selectedHairColor = color;
    notifyListeners();
  }

  // API Configuration
  static const String baseUrl = 'https://www.ailabapi.com';
  static String aiLabApiKey = AdsVariable.ca_ai_lab_tool_api;
  static const String apiKeyField = 'ailabapi-api-key';

  // Available hairstyles
  // Available hairstyles
  // Now using HairstyleData from utils

  final Map<String, String> hairColors = HairstyleData.hairColors;

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
    notifyListeners();
  }

  /// Generate task ID by submitting the image with selected hairstyle
  Future<bool> generateTaskId(
    File selectedImage,
    String hairStyle,
    BuildContext context, {
    String color = '',
  }) async {
    _setLoading(true);
    _setError(null);

    showLog("selected hairstyle is $hairStyle");
    showLog("selected color is $color");

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/portrait/effects/hairstyle-editor-pro'),
      );

      // Add headers
      request.headers[apiKeyField] = aiLabApiKey;

      // Add form fields
      request.fields['task_type'] = 'async';
      request.fields['hair_style'] = hairStyle;
      request.fields['color'] = color;
      request.fields['image_size'] = "1";

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImage.path),
      );

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      showLog("this is response $response");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        showLog("this is json response $jsonResponse");

        if (jsonResponse['error_code'] == 0) {
          taskId = jsonResponse['task_id'];
          showLog("this is task id $jsonResponse");

          if (taskId != null && taskId!.isNotEmpty) {
            _setLoading(false);
            notifyListeners();

            // Automatically start polling for results
            await pollTaskResult(context: context);
            return true;
          } else {
            showToast("Something went wrong, please try again");
            showLog("Task ID not received from server");
            _setError('Task ID not received from server');
            _setLoading(false);
            return false;
          }
        } else {
          showToast("Something went wrong, please try again");
          showLog(
            "error is ${jsonResponse['error_msg'] ?? 'Unknown error occurred'}",
          );
          _setError(jsonResponse['error_msg'] ?? 'Unknown error occurred');
          _setLoading(false);
          return false;
        }
      } else {
        showToast("Something went wrong, please try again");
        showLog("error ${response.statusCode}");
        _setError('Server error: ${response.statusCode}');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      showToast("Something went wrong, please try again");
      _setError('Network error: ${e.toString()}');
      showLog("error catch $e");
      _setLoading(false);
      return false;
    }
  }

  /// Poll for task result
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
            // Check task status
            var taskStatus = jsonResponse['task_status'];
            var data = jsonResponse['data'];

            showLog("task_status value: $taskStatus");

            if (taskStatus == 2) {
              if (data != null &&
                  data['images'] != null &&
                  data['images'].isNotEmpty) {
                resultImageUrl = data['images'][0];
                showLog("Successfully got result image: $resultImageUrl");

                if (resultImageUrl != null) {
                  showLog("this is result image first");
                  final coinProvider = Provider.of<CoinProvider>(
                    context,
                    listen: false,
                  );
                  coinProvider.decrementCoins(
                    AdsVariable.ca_reduce_coin_on_ai_lab_api,
                  );
                  _setLoading(false);
                  notifyListeners();
                  _saveImageLocally(resultImageUrl!);
                  return true;
                }
              } else {
                // Check alternative response structures
                resultImageUrl =
                    data?['result']?['image_url'] ??
                    data?['image_url'] ??
                    data?['output_image_url'];

                if (resultImageUrl != null) {
                  showLog("this is result image second");
                  showLog(
                    "Successfully got result image from alternative path: $resultImageUrl",
                  );
                  final coinProvider = Provider.of<CoinProvider>(
                    context,
                    listen: false,
                  );
                  coinProvider.decrementCoins(
                    AdsVariable.ca_reduce_coin_on_ai_lab_api,
                  );
                  _setLoading(false);
                  notifyListeners();
                  _saveImageLocally(resultImageUrl!);

                  return true;
                }
              }

              _setError('Result image not found in response');
              _setLoading(false);
              showToast("Something went wrong, please try again");
              return false;
            } else if (taskStatus == 3) {
              _setError('Task failed: ${data?['error'] ?? 'Unknown error'}');
              showToast("Something went wrong, please try again");
              _setLoading(false);
              showToast("Something went wrong, please try again");
              return false;
            } else if (taskStatus == 1) {
              // Task still processing, continue polling

              showLog(
                "Task still processing, attempt ${attempt + 1}/$maxAttempts",
              );
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

  /// Manual query for task result (if needed)
  // Future<bool> queryTaskResult(String taskIdToQuery) async {
  //   taskId = taskIdToQuery;
  //   return await pollTaskResult();
  // }

  Future<void> _saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'hairstyle_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        final prefs = await SharedPreferences.getInstance();
        final List<String> savedImages =
            prefs.getStringList('saved_generated_images') ?? [];
        savedImages.add(file.path);
        await prefs.setStringList('saved_generated_images', savedImages);

        showLog("Image saved locally: ${file.path}");
      }
    } catch (e) {
      showLog("Error saving image: $e");
    }
  }
}
