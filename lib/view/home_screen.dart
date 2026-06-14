import 'package:charmai/ads/ads_init_utils.dart';
import 'package:charmai/utils/app_constants.dart';
import 'package:charmai/utils/navigation.dart';
import 'package:charmai/view/face_swap_screen.dart';
import 'package:charmai/view/prompt_image_generation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firebase_storage_service.dart';
import '../utils/theme.dart';
import '../view_model/category_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storageService = FirebaseStorageService();


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Container(
      color: AppColors.mainAppBackground,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
              primary: false,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 200.h, top: 0),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 900.h,
                      child: ListView.builder(
                        primary: false,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: category.templates.length,
                        itemBuilder: (context, i) {
                          final template = category.templates[i];
                          final type = category.type;
                          final imageUrl = template.imageUrl;
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () {
                                if (type == "prompt") {
                                  AdsSplashUtils.onShowAds(context, () {
                                    AppNavigation.NavigationPush(
                                        context, PromptImageGenerationScreen(image: imageUrl,
                                      prompt: template.prompt ?? "",
                                      title: category.title,));
                                  });
                                } else {
                                  AdsSplashUtils.onShowAds(context, () {
                                    AppNavigation.NavigationPush(context,
                                        FaceSwapScreen(image: imageUrl, title: category.title));
                                  });
                                }
                              },
                              child: Container(
                                width: 600.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                          color: Colors.grey[900],
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                     SizedBox(height: 32.h),
                  ],
                );
              },
            ),
    );
  }
}
