import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../models/entities/store_arguments.dart';
import '../../screens/chat/chat_arguments.dart';
import '../../services/services.dart';
import 'products/create_product_screen.dart';
import 'products/product_sell_screen.dart';
import 'store/categories_screen.dart';
import 'store_detail/store_detail_screen.dart';
import 'stores_map/map_screen.dart';

class VendorRoute {
  static dynamic getRoutesWithSettings(RouteSettings settings) {
    final routes = {
      RouteList.storeDetail: (context) {
        final arguments = settings.arguments;
        if (arguments is StoreDetailArgument) {
          return StoreDetailScreen(store: arguments.store);
        }
        return errorPage('Error argument StoreDetail');
      },
      RouteList.vendorChat: (context) {
        final arguments = settings.arguments;
        if (arguments is ChatArguments) {
          return Services().firebase.renderChatScreen(
                senderUser: arguments.senderUser,
                receiverEmail: arguments.receiverEmail,
                receiverName: arguments.receiverName,
              );
        }
        return errorPage('Error argument ChatScreen');
      },
      RouteList.vendorCategory: (context) => const VendorCategoriesScreen(),
      RouteList.createProduct: (context) => CreateProductScreen(),
      RouteList.productSell: (context) => ProductSellScreen(),
      RouteList.listChat: (_) => Services().firebase.renderListChatScreen(),
      RouteList.map: (_) => const MapScreen(),
    };
    if (routes.containsKey(settings.name)) {
      return routes[settings.name!];
    }
    return (context) => errorPage('Page not found');
  }

  static Widget errorPage(String title) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(title),
        ),
      );
}
