import 'package:actual_refactoring/model/common/cursor_pagination_model.dart';
import 'package:flutter/material.dart';

import '../provider/common/pagination_provider.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider,
  }) {
    // 현재 위치가
    // 최대 길이보다 조금 덜되는 위치까지 왔다면
    // 새로운 데이터를 추가요청
    // offset - 스크롤한 현재 위치
    // maxScrollExtent - 최대 스크롤 가능한 길이
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      if (provider.state is CursorPagination) {
        // Throtling 리스트가 짧아서 pagination 조건이 계속 지속되는 경우
        // 서버 응답에서 데이터가 더 있는 경우만 실행
        if ((provider.state as CursorPagination).meta.hasMore) {
          provider.paginate(
            fetchMore: true,
          );
        }
      }
    }
  }
}
