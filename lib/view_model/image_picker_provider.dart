import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../ads/AppLifeReactor.dart';
import '../ads/appOpenAdManager.dart';
import '../utils/app_constants.dart';

class ImagePickerProvider extends ChangeNotifier{
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  File? get selectedImage => _selectedImage;

  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  /// Pick image from gallery or camera, then crop it
  Future<bool> pickImage() async {
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);
    try {
      // Step 1: Pick the image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Step 2: Crop the image immediately after picking
        final croppedFile = await _cropImage(File(image.path));

        if (croppedFile != null) {
          _selectedImage = croppedFile;

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


  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }



  /// Crop the selected image
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,

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
}