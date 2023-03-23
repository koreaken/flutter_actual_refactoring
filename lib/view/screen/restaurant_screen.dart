import 'package:actual_refactoring/view/screen/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../model/restaurant_model.dart';
import '../../provider/restaurant_provider.dart';
import '../component/pagination_list_view.dart';
import '../widgets/restaurant_card.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationListView<RestaurantModel>(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            // context.go('/restaurant/${model.id}');
            context.goNamed(
              RestaurantDetailScreen.routeName,
              params: {
                'rid': model.id,
              },
            );
          },
          child: RestaurantCard.fromModel(
            model: model,
          ),
        );
      },
    );
  }
}
