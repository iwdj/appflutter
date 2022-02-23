import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/entities/category.dart';
import '../../../services/dependency_injection.dart';
import '../services/vendor_admin.dart';

enum VendorAdminCategoryModelState { loading, loaded }

class VendorAdminCategoryModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminCategoryModelState.loading;

  /// Your Other Variables Go Here
  Map<String?, Map<String, dynamic>> map = {};
  List<Category> categories = [];
  int _page = 1;
  final int _perPage = 100;
  late SharedPreferences _sharedPreferences;

  /// Constructor
  VendorAdminCategoryModel() {
    initLocalStorage().then((value) => getAllCategories());
  }

  /// Your Defined Functions Go Here

  Future<void> initLocalStorage() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> getAllLocalCategories() async {
    var tmp = _sharedPreferences.getString('vendorCategories');
    if (tmp != null) {
      var s = json.decode(tmp);

      s.forEach((key, catMap) {
        map[key] = {};
        catMap.forEach((catKeyName, value) {
          map[key]![catKeyName] = value;
        });
      });
    }
    getAllCategories();
  }

  void getAllCategories() {
    _services
        .getVendorAdminCategoriesByPage(page: _page, perPage: _perPage)
        .then((list) {
      _page++;
      if (list.isNotEmpty) {
        categories.addAll(list);
        getAllCategories();
        getCategories('0', '');
      }
    });
  }

  void getCategories(String categoryId, String name) {
    if (map[categoryId] == null) {
      map[categoryId] = {};
      map[categoryId]!['name'] = '';
      map[categoryId]!['categories'] = [];
    }
    var tmpListCat = [];
    for (var cat in categories) {
      if (cat.parent == categoryId) {
        tmpListCat.add(cat);
      }
    }
    map[categoryId]!['name'] = name;
    map[categoryId]!['categories'] = tmpListCat;
    var s = json.encode(map);
    _sharedPreferences.setString('vendorCategories', s);
    if (tmpListCat.isNotEmpty) {
      for (var category in tmpListCat) {
        getCategories(category.id, category.name ?? '');
      }
    }
  }
}
