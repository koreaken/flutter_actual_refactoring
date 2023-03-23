import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../../common/provider/pagination_provider.dart';
import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  // Cursorpagination 이 아니다? 데이터가 없다는 뜻으로 return;
  if (state is! CursorPagination) {
    return null;
  }

  // id 에 해당하는 데이터를 가져오는 역할
  return state.data.firstWhereOrNull((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);

    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

class RestaurantStateNotifier extends PaginationProvider<RestaurantModel, RestaurantRepository> {

  RestaurantStateNotifier({
    required super.repository,
  });

  getDetail({
    required String id,
  }) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면 (CursorPagination 이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await paginate();
    }

    // state가 CursorPagination이 아닐 때 그냥 리턴
    if (state is! CursorPagination) {
      return;
    }

    // restaurant model 형태의 값
    final pState = state as CursorPagination;

    // restaurant detail model 형태의 값
    final resp = await repository.getRestaurantDetail(id: id);

    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
    // 요청 id: 10
    // list.where((e) => e.id == 10)) 데이터 없음
    // 데이터가 없을 때는 그냥 캐시의 끝에다가 데이터를 추가해버린다.
    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3),
    // RestaurantModel(10)],
    if (pState.data.where((e) => e.id == id).isEmpty) {
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ]
      );
    } else {
      // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
      // id : 2인 친구를 Detail 모델을 가져와라
      // getDetail(id: 2);
      // [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)]
      // 이미 존재하고 있는 데이터
      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>(
              // id 가 2인 모델을 찾아서 id가 2인 모델 위치에 resp 데이터(detail) 로 바꿔준다.
              (e) => e.id == id ? resp : e,
            )
            .toList(),
      );
    }

  }
}
