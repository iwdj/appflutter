import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../shop_model/export.dart';
import '../shop_widget/shop_review_item.dart';

class ShopReviewScreen extends StatefulWidget {
  const ShopReviewScreen({Key? key}) : super(key: key);

  @override
  _ShopReviewScreenState createState() => _ShopReviewScreenState();
}

class _ShopReviewScreenState extends State<ShopReviewScreen> {
  final _controller = RefreshController();

  void _onRefresh() {
    final model = Provider.of<ShopReviewModel>(context, listen: false);
    model.getReviews().then((value) {
      _controller.refreshCompleted();
      if (value.isEmpty) {
        _controller.loadNoData();
        return;
      }
      _controller.loadComplete();
    });
  }

  void _onLoadMore() {
    final model = Provider.of<ShopReviewModel>(context, listen: false);
    model.loadReviews().then((value) {
      if (value.isEmpty) {
        _controller.loadNoData();
        return;
      }
      _controller.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).reviews,
          style: theme.textTheme.headline6,
        ),
      ),
      body: Consumer<ShopReviewModel>(builder: (_, model, __) {
        final _isEmpty =
            model.reviews.isEmpty && model.state == ShopReviewState.loaded;
        final _isLoading = model.state == ShopReviewState.loading;
        return SmartRefresher(
          controller: _controller,
          enablePullDown: true,
          enablePullUp: true,
          onLoading: _onLoadMore,
          onRefresh: _onRefresh,
          child: _isEmpty
              ? Center(
                  child: Text(S.of(context).noData),
                )
              : ListView.builder(
                  itemBuilder: (_, index) => _isLoading
                      ? const ShopReviewItem.loading()
                      : ShopReviewItem(review: model.reviews[index]),
                  itemCount: _isLoading ? 5 : model.reviews.length,
                ),
        );
      }),
    );
  }
}
