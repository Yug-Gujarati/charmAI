import 'dart:convert';
import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;


class FirebaseStorageService {
  final storage = FirebaseStorage.instance;
  
  // The bucket name is used to construct public URLs
  String get bucket => storage.bucket;

  Future<Map<String, dynamic>> fetchCategoryJson() async {
    try {
      // We still need to get the download URL for the JSON config file once
      final ref = storage.ref("categories/master_config.json");
      final url = await ref.getDownloadURL();

      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      log("DOWNLOADED JSON: $json");
      return json;
    } catch (e) {
      log("Error fetching category JSON: $e");
      return {"categories": []};
    }
  }

  /// Construct a public URL for an image path in Firebase Storage.
  /// This is free and does not count towards Firebase Billing (Class B operations).
  String getPublicUrl(String path) {
    if (path.isEmpty) return "";
    
    // Convert path/to/image.webp -> path%2Fto%2Fimage.webp
    final encodedPath = Uri.encodeComponent(path);
    
    // Firebase Public URL format
    return "https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media";
  }
}