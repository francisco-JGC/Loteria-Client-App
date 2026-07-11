import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/draw_result.dart';
import '../../domain/repositories/results_repository.dart';

class LatestResultsController extends AsyncNotifier<List<DrawResult>> {
  late final _repository = getIt<ResultsRepository>();

  @override
  Future<List<DrawResult>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<DrawResult>> _fetch() async {
    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 3));
    final result = await _repository.listResults(
      ListDrawResultsQuery(from: since, limit: 200),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }
}

final latestResultsControllerProvider = AsyncNotifierProvider<
    LatestResultsController, List<DrawResult>>(LatestResultsController.new);
