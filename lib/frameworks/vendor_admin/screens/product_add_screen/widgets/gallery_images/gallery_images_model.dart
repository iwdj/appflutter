import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

import '../../../../../../models/entities/product.dart';
import '../../../../../../models/entities/user.dart';
import '../../../../../../services/dependency_injection.dart';
import '../../../../services/vendor_admin.dart';

enum VendorAdminGalleryImagesModelState { loading, loaded, noMore }

class VendorAdminGalleryImagesModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminGalleryImagesModelState.loaded;

  /// Your Other Variables Go Here
  final ImagePicker imagePicker = ImagePicker();
  final List<String?> imagesFromServer = [];
  int _pageFromServer = 0;
  final int _perPageFromServer = 10;
  User? user;
  Product? product;
  final ScrollController galleryController = ScrollController();

  /// Constructor
  VendorAdminGalleryImagesModel(this.user) {
    galleryController.addListener(() {
      if (galleryController.position.extentAfter < 300) {
        _loadMoreImagesFromServer();
      }
    });
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here
  Future<XFile?>? takeImageFromCamera() async {
    return await imagePicker.pickImage(source: ImageSource.camera);
  }

  Future<List<Asset>> chooseImagesFromGallery() async {
    return await MultiImagePicker.pickImages(maxImages: 5);
  }

  Future<void> loadImagesFromServer() async {
    if (state == VendorAdminGalleryImagesModelState.loading ||
        state == VendorAdminGalleryImagesModelState.noMore) {
      return;
    }
    _updateState(VendorAdminGalleryImagesModelState.loading);

    _pageFromServer++;

    var list = await _services.getImagesByVendor(
        page: _pageFromServer, perPage: _perPageFromServer, vendorId: user!.id);
    if (list.isEmpty) {
      _updateState(VendorAdminGalleryImagesModelState.noMore);
      return;
    }
    imagesFromServer.addAll(list);

    _updateState(VendorAdminGalleryImagesModelState.loaded);
  }

  Future<void> _loadMoreImagesFromServer() async {
    if (state == VendorAdminGalleryImagesModelState.loading ||
        state == VendorAdminGalleryImagesModelState.noMore) {
      return;
    }

    _updateState(VendorAdminGalleryImagesModelState.loading);

    _pageFromServer++;

    var list = await _services.getImagesByVendor(
        page: _pageFromServer, perPage: _perPageFromServer, vendorId: user!.id);
    if (list.isEmpty) {
      _updateState(VendorAdminGalleryImagesModelState.noMore);
      return;
    }
    imagesFromServer.addAll(list);

    _updateState(VendorAdminGalleryImagesModelState.loaded);
  }
}
