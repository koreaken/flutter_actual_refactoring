import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/rating_model.dart';
import '../communicate/repository/restaurant_rating_repository.dart';
import '../model/common/cursor_pagination_model.dart';
import 'common/pagination_provider.dart';

// CursorPaginationBase - 상태의 타입
final restaurantRatingProvider = StateNotifierProvider.family<
    RestaurantRatingStateNotifier, CursorPaginationBase, String>((ref, id) {
  final repo = ref.watch(restaurantRatingRepositoryProvider(id));

  return RestaurantRatingStateNotifier(repository: repo);
});

class RestaurantRatingStateNotifier
    extends PaginationProvider<RatingModel, RestaurantRatingRepository> {
  RestaurantRatingStateNotifier({
    required super.repository,
  });
}
