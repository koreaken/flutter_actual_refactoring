import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/product_model.dart';
import '../../provider/product_provider.dart';
import 'restaurant_detail_screen.dart';
import '../component/pagination_list_view.dart';
import '../widgets/product_card.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      provider: productProvider,
      itemBuilder: <ProductModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => RestaurantDetailScreen(id: model.restaurant.id),
            //   ),
            // );
            context.goNamed(
              RestaurantDetailScreen.routeName,
              params: {
                'rid': model.restaurant.id,
              },
            );
          },
          child: ProductCard.fromProductModel(
            model: model,
          ),
        );
      },
    );
  }
}
