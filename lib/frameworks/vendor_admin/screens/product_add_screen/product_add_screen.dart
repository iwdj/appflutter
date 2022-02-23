import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/product_attribute.dart';
import '../../../../models/entities/vendor_admin_variation.dart';
import '../../../../widgets/common/edit_product_info_widget.dart';
import '../../../../widgets/common/expansion_info.dart';
import '../../common_widgets/add_attribute_widget.dart';
import '../../common_widgets/product_attribute_widget.dart';
import '../../common_widgets/status_dropdown.dart';
import '../../common_widgets/variable_types_dropdown.dart';
import '../../common_widgets/variation_widget.dart';
import '../../models/authentication_model.dart';
import '../../models/category_model.dart';
import '../product_add_screen/widgets/choose_image_widget/choose_image_widget.dart';
import '../product_add_screen/widgets/gallery_images/gallery_images.dart';
import 'product_add_screen_model.dart';
import 'widgets/categories_widget.dart';
import 'widgets/gallery_images/gallery_images_model.dart';

class VendorAdminProductAddScreen extends StatefulWidget {
  final Function? onCallBack;
  final List<ProductAttribute>? defaultAttributes;
  const VendorAdminProductAddScreen(
      {Key? key, this.onCallBack, this.defaultAttributes})
      : super(key: key);

  @override
  _VendorAdminProductAddScreenState createState() =>
      _VendorAdminProductAddScreenState();
}

class _VendorAdminProductAddScreenState
    extends State<VendorAdminProductAddScreen> {
  var productAttributes;
  late var comparedProductAttributes;
  var variations = <VendorAdminVariation>[];

  Map<dynamic, dynamic> _getAttributes(List<ProductAttribute> list) {
    var productAttributes = <dynamic, dynamic>{};

    for (var attr in list) {
      productAttributes[attr.name] = {
        'default': true,
        'isActive': false,
        'options': [...attr.options!],
        'slugs': [...attr.optionSlugs],
        'variation': attr.isVariation,
        'visible': attr.isVisible,
        'slug': attr.slug,
        'name': attr.name,
      };
    }

    return productAttributes;
  }

  void _addAnAttribute(String name) {
    productAttributes[name] = {
      'default': false,
      'isActive': false,
      'options': [],
      'variation': false,
      'visible': false,
      'slug': name,
      'slugs': [],
      'name': name,
    };
    comparedProductAttributes[name] = {
      'default': false,
      'isActive': false,
      'options': [],
      'slugs': [],
      'variation': false,
      'visible': false,
      'slug': name,
      'name': name,
    };
    setState(() {});
  }

  void _deleteAttribute(String? name) {
    productAttributes.remove(name);
    comparedProductAttributes.remove(name);
    setState(() {});
  }

  @override
  void initState() {
    productAttributes = _getAttributes(widget.defaultAttributes!);
    comparedProductAttributes = _getAttributes(widget.defaultAttributes!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    final map =
        Provider.of<VendorAdminCategoryModel>(context, listen: false).map;
    Map<String, dynamic>? defaultCurrency = kAdvanceConfig['DefaultCurrency'];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChooseImageWidgetModel>(
          create: (_) => ChooseImageWidgetModel(user),
        ),
        ChangeNotifierProvider<VendorAdminGalleryImagesModel>(
          create: (_) => VendorAdminGalleryImagesModel(user),
        ),
        ChangeNotifierProvider<VendorAdminProductAddScreenModel>(
          create: (_) => VendorAdminProductAddScreenModel(user, map),
        ),
      ],
      child: Consumer<VendorAdminProductAddScreenModel>(
        builder: (_, model, __) => Stack(
          children: [
            Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: CupertinoNavigationBar(
                backgroundColor: Theme.of(context).primaryColorLight,
                middle: Text(
                  S.of(context).createProduct,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              floatingActionButton: InkWell(
                onTap: () async {
                  await model.createProduct(productAttributes, variations);
                  Navigator.pop(context);
                  widget.onCallBack!();
                },
                child: Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .backgroundColor,
                  ),
                  child: Center(
                      child: Text(
                    S.of(context).uploadProduct,
                    style: const TextStyle(color: Colors.white),
                  )),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 15.0),
                        Text(
                          S.of(context).status,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(width: 15.0),
                        StatusDropdown(
                          onCallBack: (status) =>
                              model.setProductStatus(status!),
                          status: model.status,
                        ),
                        const Expanded(child: SizedBox(width: 10.0)),
                        Text(
                          S.of(context).productType,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(width: 15.0),
                        VariableTypesDropdown(
                          onCallBack: (type) => model.setProductType(type!),
                          type: model.type,
                        ),
                        const SizedBox(width: 15.0),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    VendorAdminProductCategoriesWidget(
                      product: model.product,
                    ),
                    EditProductInfoWidget(
                      controller: model.productNameController,
                      label: S.of(context).name,
                    ),
                    if (model.type != 'variable')
                      EditProductInfoWidget(
                        controller: model.regularPriceController,
                        label: S.of(context).regularPrice,
                        keyboardType: TextInputType.number,
                        prefixIcon: Container(
                          width: 1,
                          height: 1,
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 5.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          decoration: const BoxDecoration(
                            border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Center(
                            child: Text(
                              defaultCurrency!['symbol'],
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                      ),
                    if (model.type != 'variable')
                      EditProductInfoWidget(
                        controller: model.salePriceController,
                        label: S.of(context).salePrice,
                        keyboardType: TextInputType.number,
                        prefixIcon: Container(
                          width: 1,
                          height: 1,
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 5.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          decoration: const BoxDecoration(
                            border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Center(
                            child: Text(
                              defaultCurrency!['symbol'],
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                      ),
                    EditProductInfoWidget(
                      controller: model.sKUController,
                      label: S.of(context).sku,
                    ),
                    EditProductInfoWidget(
                      controller: model.tagsController,
                      label: S.of(context).tags,
                    ),
                    if (model.product.manageStock)
                      EditProductInfoWidget(
                        controller: model.stockQuantity,
                        label: S.of(context).stockQuantity,
                        keyboardType: TextInputType.number,
                      ),
                    Row(
                      children: [
                        Checkbox(
                            value: model.product.manageStock,
                            onChanged: (val) => model.updateManageStock()),
                        Text(S.of(context).manageStock),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: ExpansionInfo(
                        title: S.of(context).attributes,
                        children: [
                          Column(
                            children: List.generate(
                              comparedProductAttributes.keys.length,
                              (index) {
                                final key = comparedProductAttributes.keys
                                    .toList()[index];
                                return ProductAttributeWidget(
                                  attributeMap: productAttributes[key],
                                  attributeKey: key,
                                  comparedMap: comparedProductAttributes[key],
                                  hideVariation: model.type == 'variable',
                                  onDelete: _deleteAttribute,
                                );
                              },
                            ),
                          ),
                          AddAttributeWidget(
                            onCallBack: _addAnAttribute,
                          ),
                          if (model.type == 'variable')
                            Text(
                              'Re-open the variation tab to apply new attribute and settings',
                              style: Theme.of(context).textTheme.caption,
                            ),
                        ],
                      ),
                    ),
                    if (model.type == 'variable')
                      VariationWidget(
                        productAttributes: productAttributes,
                        variations: variations,
                      ),
                    const SizedBox(height: 10),
                    //SaleDatePickers(),
                    ChooseImageWidget(),
                    VendorAdminProductGalleryImages(),

                    EditProductInfoWidget(
                      controller: model.shortDescription,
                      label: S.of(context).shortDescription,
                    ),
                    EditProductInfoWidget(
                      controller: model.description,
                      label: S.of(context).description,
                      isMultiline: true,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (model.state == VendorAdminProductAddScreenModelState.loading)
              Container(
                width: size.width,
                height: size.height,
                color: Colors.grey.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
