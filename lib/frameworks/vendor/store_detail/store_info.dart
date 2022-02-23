import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools/image_tools.dart';
import '../../../models/index.dart';

class StoreInfo extends StatelessWidget {
  final Store store;
  const StoreInfo({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildContact(IconData icon, String data,
        {VoidCallback? onCallBack}) {
      return GestureDetector(
        onTap: onCallBack,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 20.0,
              ),
              Icon(icon, color: onCallBack != null ? Colors.blue : null),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                  child: Text(
                data,
                style:
                    TextStyle(color: onCallBack != null ? Colors.blue : null),
              )),
              const SizedBox(
                width: 20.0,
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMap() {
      if (isDesktop || kIsWeb) {
        return const SizedBox();
      }
      if (store.lat == null || store.long == null) {
        return const SizedBox();
      }

      var googleMapsApiKey;
      if (isIos) {
        googleMapsApiKey = kGoogleAPIKey['ios'];
      } else if (isAndroid) {
        googleMapsApiKey = kGoogleAPIKey['android'];
      } else {
        googleMapsApiKey = kGoogleAPIKey['web'];
      }

      var mapURL = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'size': '800x600',
          'center': '${store.lat},${store.long}',
          'zoom': '13',
          'maptype': 'roadmap',
          'markers': 'color:red|label:C|${store.lat},${store.long}',
          'key': '$googleMapsApiKey'
        },
      );

      return ImageTools.image(
        url: mapURL.toString(),
        width: MediaQuery.of(context).size.width,
        height: 300,
      );
    }

    void _launchURL(url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Column(
      children: [
        const SizedBox(
          height: 20.0,
        ),
        if (store.address != null && store.address!.isNotEmpty)
          _buildContact(Icons.location_on,
              '${store.address!}${store.address!}${store.address!}${store.address!}'),
        if (store.email != null && store.email!.isNotEmpty)
          _buildContact(Icons.email, store.email!, onCallBack: () {
            _launchURL('mailto:' + store.email!);
          }),
        if (store.phone != null && store.phone!.isNotEmpty)
          _buildContact(Icons.phone, store.phone!, onCallBack: () {
            _launchURL('tel:' + store.phone!);
          }),
        Flexible(child: _buildMap()),
      ],
    );
  }
}
