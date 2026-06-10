import 'package:charmai/repository/category_repository.dart';
import 'package:charmai/utils/app_constants.dart';
import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier{
  final repository = CategoryRepository();

  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadCategories() async{
    showLog("star loading categories");
    if (_categories.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    _categories = await repository.getCategories();

    _isLoading = false;
    notifyListeners();
  }


}