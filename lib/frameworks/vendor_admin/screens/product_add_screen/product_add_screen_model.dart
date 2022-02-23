import 'package:flutter/cupertino.dart';
import '../../../../common/config.dart';

import '../../../../models/entities/category.dart';
import '../../../../models/entities/product.dart';
import '../../../../models/entities/user.dart';
import '../../../../models/entities/vendor_admin_variation.dart';
import '../../../../services/dependency_injection.dart';
import '../../services/vendor_admin.dart';

enum VendorAdminProductAddScreenModelState { loading, loaded }

class VendorAdminProductAddScreenModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminProductAddScreenModelState.loading;

  /// Your Other Variables Go Here
  Product product = Product();
  User? user;
  var featuredImage;
  List<dynamic> galleryImages = [];
  List<Category> categories = [];
  Map<String?, Map<String, dynamic>> map = {};
  List<Category> currentCategories = [];
  List<Category> searchedCategories = [];
  List<List<Category>> navigatedCategories = [];
  int currentPageView = 0;
  List<String> selectedCategoryIds = [];
  String status =
      (kVendorConfig['DisablePendingProduct'] ?? false) ? 'publish' : 'pending';
  String type = 'simple';
  final FocusNode focusNode = FocusNode();
  final PageController pageController = PageController();
  final searchController = TextEditingController();
  final productNameController = TextEditingController();
  final regularPriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final sKUController = TextEditingController();
  final stockQuantity = TextEditingController();
  final shortDescription = TextEditingController();
  final description = TextEditingController();
  final tagsController = TextEditingController();

  /// Constructor
  VendorAdminProductAddScreenModel(this.user, this.map) {
    getCategories();
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  void setProductType(String type) {
    this.type = type;
    notifyListeners();
  }

  void setProductStatus(String status) {
    this.status = status;
    notifyListeners();
  }

  Future<void> getCategories() async {
    for (var category in map['0']?['categories']) {
      if (category is Category) {
        categories.add(category);
      } else {
        categories.add(Category.fromJson(category));
      }
    }
    navigatedCategories.add(categories);
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  /// Image parameter will be either PickedFile or String(url)
  void updateFeaturedImage(dynamic image) {
    featuredImage = image;
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  /// Image parameter will be either PickedFile or List or String(url) or Asset(from multi picker)
  void updateGalleryImages(dynamic image) {
    if (image is List) {
      for (var item in image) {
        galleryImages.add(item);
      }
    } else {
      galleryImages.add(image);
    }
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  void removeImageFromGallery(dynamic image) {
    galleryImages.remove(image);
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  dynamic updateSelectedCategories(String? id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id!);
    }
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  void updateCategories(List<Category> categories) {
    this.categories = categories;
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  /// Vendor Product Category Edit Screen
  void searchCategory() {
    if (searchController.text != '') {
      searchedCategories.clear();
      for (var cat in categories) {
        if (cat.name!
            .toLowerCase()
            .contains(searchController.text.toLowerCase())) {
          searchedCategories.add(cat);
        }
      }
      notifyListeners();
    } else {
      searchedCategories.clear();
      notifyListeners();
    }
  }

  void requestFocus() {
    focusNode.requestFocus();
    searchedCategories.clear();
  }

  void updatePage(Category category) async {
    focusNode.unfocus();
    await loadSubCategories(category.id);
    if (navigatedCategories.length > currentPageView + 1) {
      currentCategories.add(category);
      notifyListeners();
      currentPageView++;
      await pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void goBack() {
    if (currentPageView > 0) {
      currentPageView--;
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      navigatedCategories.removeLast();
      currentCategories.removeLast();
      notifyListeners();
    }
  }

  Future<void> loadSubCategories(String? categoryId) async {
    var list = <Category>[];
    map[categoryId]!['categories'].forEach((category) {
      if (category is Category) {
        list.add(category);
      } else {
        list.add(Category.fromJson(category));
      }
    });
    if (list.isNotEmpty) {
      navigatedCategories.add(list);
    }
  }

  void requestUnFocus() {
    focusNode.unfocus();
    searchedCategories.clear();
    searchController.clear();
    notifyListeners();
  }

  Future<void> createProduct(Map<dynamic, dynamic>? productAttributes,
      List<VendorAdminVariation> variations) async {
    _updateState(VendorAdminProductAddScreenModelState.loading);
    product.name = productNameController.text;
    product.regularPrice = regularPriceController.text;
    product.salePrice = salePriceController.text;
    product.sku = sKUController.text;
    product.stockQuantity =
        int.parse(stockQuantity.text.isNotEmpty ? stockQuantity.text : '0');
    product.shortDescription = shortDescription.text;
    product.description = description.text;
    product.categoryIds = selectedCategoryIds;
    product.status = status;
    product.type = type;
    product = await _services.createVendorAdminProduct(
        cookie: user!.cookie!,
        product: product,
        images: galleryImages,
        featuredImage: featuredImage,
        status: status,
        tags: tagsController.text,
        productAttributes: productAttributes,
        variations: variations);
    _updateState(VendorAdminProductAddScreenModelState.loaded);
  }

  void updateManageStock() {
    product.manageStock = !product.manageStock;
    notifyListeners();
  }
}
