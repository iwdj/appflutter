import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common/constants.dart';
import '../../../../../common/tools.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/product.dart';
import '../../../../../models/index.dart';
import '../../../models/category_model.dart';
import '../../../models/product_attribute_model.dart';
import '../../../models/product_list_screen_model.dart';
import '../../product_edit_screen/product_edit_screen.dart';

class VendorAdminProductListCardWidget extends StatelessWidget {
  final Product? product;

  const VendorAdminProductListCardWidget({Key? key, this.product})
      : super(key: key);

  void _onNavigate(context, attributeModel) {
    final model = Provider.of<VendorAdminCategoryModel>(context, listen: false);
    final model2 =
        Provider.of<VendorAdminProductListScreenModel>(context, listen: false);

    final productAttributes = attributeModel.defaultAttributes;
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: model,
          child: VendorAdminProductEditScreen(
            product: product,
            onCallBack: () {
              attributeModel.getDefaultAttributes();
              model2.getVendorProductList();
            },
            defaultAttributes: productAttributes,
          ),
        ),
      ),
    );
  }

  /// TODO: Quick fix. Need to improve
  String convertType(String type, context) {
    if (type.toLowerCase() == 'simple') {
      return S.of(context).simple.toUpperCase();
    }
    if (type.toLowerCase() == 'variable') {
      return S.of(context).variable.toUpperCase();
    }
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final attributeModel =
        Provider.of<VendorAdminProductAttributeModel>(context);
    return InkWell(
      onTap: () => _onNavigate(context, attributeModel),
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: ImageTools.image(
                  url: product!.vendorAdminImageFeature ?? kDefaultImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 5.0),
                  Text(
                    product!.name!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product!.onSale!) ...[
                        Flexible(
                          child: Text(
                            PriceTools.getCurrencyFormatted(
                              product!.salePrice,
                              currencyRate,
                              currency: currency,
                            )!,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.blue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          PriceTools.getCurrencyFormatted(
                              product!.regularPrice, currencyRate,
                              currency: currency)!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                      if (!product!.onSale!)
                        Text(
                          PriceTools.getCurrencyFormatted(
                              product!.regularPrice, currencyRate,
                              currency: currency)!,
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product!.manageStock
                              ? '${S.of(context).stock}: ${product!.stockQuantity ?? 0}'
                              : '',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                      if (product!.type != null)
                        Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Text(
                              convertType(product!.type!, context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
