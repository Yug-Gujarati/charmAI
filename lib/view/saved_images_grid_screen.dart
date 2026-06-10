import 'dart:io';

import 'package:charmai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ads/ads_init_utils.dart';
import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/dialog.dart';
import '../utils/navigation.dart';
import 'Image_priview_screen.dart';

class SavedImages extends StatefulWidget {
  const SavedImages({Key? key}) : super(key: key);

  @override
  State<SavedImages> createState() => _SavedImagesState();
}

class _SavedImagesState extends State<SavedImages> {


  late Future<List<File>> _savedImagesFuture;

  @override
  void initState() {
    FirebaseAnalyticsService.logEvent(eventName: "CA_SAVED_IMAGE_SCREEN");
    _savedImagesFuture = _loadSavedImages();
    super.initState();
  }


  Future<List<File>> _loadSavedImages() async {
    showLog("Loading saved images");
    final prefs = await SharedPreferences.getInstance();
    final List<String> paths =
        prefs.getStringList('saved_generated_images') ?? [];
    showLog("Total paths found: ${paths.length}");

    // Filter out any paths that no longer exist.
    return paths
        .map((p) => File(p))
        .where((file) => file.existsSync())
        .toList();
  }



  Future<void> _deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      final prefs = await SharedPreferences.getInstance();
      final List<String> paths =
          prefs.getStringList('saved_generated_images') ?? [];
      paths.remove(filePath);
      await prefs.setStringList('saved_generated_images', paths);
      setState(() {});
      showToast("Image deleted");
    } catch (e) {
      showLog("Error deleting image: $e");
      showToast("Failed to delete image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainAppBackground,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<File>>(
                future: _savedImagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(
                      child: CircularProgressIndicator(
                        color: AppColors.secondaryText,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: CustomText(
                        text: AppLocalizations.of(context)?.errorloadingimage ??'Error loading images',
                        fontSize: 40,
                        textColor: Colors.redAccent,
                        width: 600,
                        maxline: 1,
                        align: TextAlign.center,
                      ),
                    );
                  }

                  final images = snapshot.data ?? [];

                  if (images.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         Image.asset("assets/priview/nodata.png", height: 500.h,),

                          CustomText(
                            text: AppLocalizations.of(context)?.nocreationyet ??'No creations yet',
                            fontSize: 50,
                            textColor: Colors.white,
                            width: 600,
                            maxline: 1,
                            align: TextAlign.center,
                            fontFamily: 'medium',
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.only(top: 20.h, bottom: 50.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30.w,
                      mainAxisSpacing: 30.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final file = images[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                        AdsSplashUtils.onShowAds(context, () {
                          AppNavigation.NavigationPush(
                            context,
                            ImagePriviewScreen(image: file),
                          );
                        });
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.r),
                                child: Hero(
                                  tag: file.path,
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 15.h,
                            right: 15.w,
                            child: CustomeButtomWithImage(
                              height: 100.h,
                              width: 100.w,
                              image: "assets/priview/delete.png",
                              onTap: () {
                                DialogService.deleteDialog(context, (){_deleteImage(file.path);});
                              },
                              isShowAd: false,
                              child: const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
