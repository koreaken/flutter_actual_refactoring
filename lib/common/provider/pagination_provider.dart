import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cursor_pagination_model.dart';
import '../model/model_with_id.dart';
import '../model/pagination_params.dart';
import '../repository/base_pagination_repository.dart';

class _PaginationInfo {
  final int fetchCount;
  final bool fetchMore;
  final bool forceRefetch;

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceRefetch = false,
  });
}

class PaginationProvider<
T extends IModelWithId,
U extends IBasePaginationRepository<T>
> extends StateNotifier<CursorPaginationBase> {
  final U repository;
  final paginationThrottle = Throttle(
    Duration(seconds: 3),
    initialValue: _PaginationInfo(),
    checkEquality: false,
  );

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();

    paginationThrottle.values.listen(
      (state) {
        _throttledPagination(state);
      },
    );
  }

  Future<void> paginate({
    int fetchCount = 20,
    // true - 추가로 데이터 더 가져오기
    // false - 새로고침 (현재 상태를 덮어씌움)
    bool fetchMore = false,
    // 강제로 다시 로딩하기 (데이터 새로고침)
    // true - CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {

      paginationThrottle.setValue(_PaginationInfo(
        fetchMore: fetchMore,
        fetchCount: fetchCount,
        forceRefetch: forceRefetch,
      ));

  }

  _throttledPagination(_PaginationInfo info) async {
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;

    try {
      // 5가지 가능성 - state 상태
      // 1) CursorPagination - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
      // 3) CursorPaginationError - 에러가 있는 상태
      // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올 때
      // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을 때

      // 바로 반환하는 상황
      // 1) hasMore - false : 기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면 (더 호출할 필요 없겠지)
      // 2) 로딩중 - fetchMore : true (중복 호출 막기 위함. 로딩중인데 또 같은 id로 또 호출하는 경우 막기)
      //    fetchMore가 아닐 때 - 새로고침 의도가 있을 수 있다
      if (state is CursorPagination && !forceRefetch) {
        // CursorPagination : 가져온 데이터가 있음을 나타냄
        // base 타입이지만, 조건문을 통해 CursorPagination 임을 분명하게 알 수 있어서 as 선언
        final pState = state as CursorPagination;

        if (!pState.meta.hasMore) {
          // 데이터가 더 없다.
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2번 반환
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }
      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        // after 없음 - copyWith 를 통해 재선언
        // count 에서 fetchCount 대입은
        // 서버에서 기본적으로 count 값 제공하지만 client에서 임의 값을 줄 수 있어서
        // count 또한 copyWith 를 통해 재선언 가능
        count: fetchCount,
      );

      // fetchMore
      // 데이터를 추가로 더 가져오는 상황
      // fetchMore 는 무조건 데이터를 가지고 있는 상황을 의미
      if (fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 나머지 상황 - 데이터를 처음부터 가져오는 상황
      else {
        // 만약에 데이터가 있는 상황이라면
        // 기존 데이터로 보존한 채로 Fetch (API 요청)을 진행
        if (state is CursorPagination && !forceRefetch) {
          // 새로운 데이터가 들어오면 기존 데이터를 대체하면 사용자 경험에서 굿
          // 빠르다고 인식, 기존 데이터 볼 수도 있고
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          // forceRefetch 가 true 는 완전히 새롭게 로딩하는 거니까
          state = CursorPaginationLoading(); // 화면 데이터를 굳이 띄우지 않아도 된다.
        }
      }

      // 상기 조건문에 따라 (paginationParams 선언을 보면)
      // resp 는
      // 처음 가져온 데이터이거나
      // 추가 데이터이거나
      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        // 로딩 끝난 상태에서 CursorPagination 이 된다.
        // 왜냐? retrofit > paginate 반환 타입이 Future<CursorPagination<RestaurantModel>> 이니까
        state = resp.copyWith(
          // meta는 최신 데이터니까 그대로 두고
          // data는 기존에 추가로 가져온 데이터를 합친다.
            data: [
              ...pState.data,
              ...resp.data,
            ]);
      } else {
        state = resp; // 조건문을 타거니까 마지막은 처음 가져온 데이터가 되는 거지
      }

    } catch (e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}