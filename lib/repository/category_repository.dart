import 'package:charmai/services/firebase_storage_service.dart';

import '../ads/AdsVariable.dart';
import '../models/category_model.dart';
import '../utils/app_constants.dart';

class CategoryRepository {
  final firebaseService = FirebaseStorageService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final json = await firebaseService.fetchCategoryJson();
      final jsonVersion = json["version"];

      final storedVersion = await AdsVariable.getVersion();

      if (jsonVersion != null && storedVersion != jsonVersion) {
        showLog("new json version detected");
        await AdsVariable.saveVersion(jsonVersion);
      }
      if (json["categories"] == null) {
        showLog("ERROR: categories missing in JSON");
        return [];
      }

      final categories = (json["categories"] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();


      for (var category in categories) {
        for (var template in category.templates) {
         // template.imageUrl = firebaseService.getPublicUrl(template.image);
          String baseUrl = firebaseService.getPublicUrl(template.image);
          template.imageUrl = "$baseUrl&v=$jsonVersion";
        }
      }

      return categories;
    } catch (e) {
      showLog("CRITICAL ERROR in getCategories: $e");
      return [];
    }
  }

}