import '../../../model/common/cursor_pagination_model.dart';
import '../../../model/common/model_with_id.dart';
import '../../../model/common/pagination_params.dart';

abstract class IBasePaginationRepository<T extends IModelWithId> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
