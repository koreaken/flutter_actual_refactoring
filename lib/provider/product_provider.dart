import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../communicate/repository/product_repository.dart';
import '../model/common/cursor_pagination_model.dart';
import '../model/product_model.dart';
import 'common/pagination_provider.dart';

final productProvider = StateNotifierProvider<ProductStateNotifier, CursorPaginationBase>((ref) {
  final repo = ref.watch(productRepositoryProvider);

  return ProductStateNotifier(repository: repo);
});

class ProductStateNotifier extends PaginationProvider<ProductModel, ProductRepository> {
  ProductStateNotifier({
    required super.repository,
  });
}
