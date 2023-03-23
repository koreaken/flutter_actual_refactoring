import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../../common/const/data.dart';
import '../../common/dio/dio.dart';
import '../../common/model/cursor_pagination_model.dart';
import '../../common/model/pagination_params.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../rating/model/rating_model.dart';

part 'restaurant_rating_repository.g.dart';

// family 선언 이유 - 
// http://ip/restaurant/:rid/rating 이니까 어떤 레스토랑에 대해 요청을 할 건지 지정해야 해서 family 선언
final restaurantRatingRepositoryProvider = Provider.family<
    RestaurantRatingRepository,
    String>((ref, id) {
  final dio = ref.watch(dioProvider);
  
  return RestaurantRatingRepository(dio, baseUrl: 'http://$ip/restaurant/$id/rating');
});

// http://ip/restaurant/:rid/rating
@RestApi()
abstract class RestaurantRatingRepository implements IBasePaginationRepository<RatingModel>{
  factory RestaurantRatingRepository(Dio dio, {String baseUrl}) =
      _RestaurantRatingRepository;

  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RatingModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });
}
