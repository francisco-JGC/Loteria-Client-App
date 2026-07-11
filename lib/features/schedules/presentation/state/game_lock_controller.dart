import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/draw_schedule.dart';
import '../../domain/repositories/schedules_repository.dart';

const _postDrawGraceMinutes = 3;
const _tickInterval = Duration(seconds: 15);

class GameLockState extends Equatable {
  const GameLockState({
    required this.status,
    this.currentDrawAt,
    this.currentCutoffMinutes,
    this.reopenAt,
    this.nextDrawAt,
    this.nextCutoffMinutes,
    this.errorMessage,
  });

  const GameLockState.unknown() : this(status: GameLockStatus.unknown);

  final GameLockStatus status;
  final DateTime? currentDrawAt;
  final int? currentCutoffMinutes;
  final DateTime? reopenAt;
  final DateTime? nextDrawAt;
  final int? nextCutoffMinutes;
  final String? errorMessage;

  bool get isLocked => status == GameLockStatus.locked;
  bool get isOpen => status == GameLockStatus.open;

  @override
  List<Object?> get props => [
        status,
        currentDrawAt,
        currentCutoffMinutes,
        reopenAt,
        nextDrawAt,
        nextCutoffMinutes,
        errorMessage,
      ];
}

enum GameLockStatus { unknown, open, locked, noSchedules, error }

class GameLockController extends Notifier<GameLockState> {
  GameLockController(this.gameId);

  final String gameId;

  late final _repository = getIt<SchedulesRepository>();
  List<DrawSchedule>? _schedules;
  Timer? _timer;

  @override
  GameLockState build() {
    ref.onDispose(() => _timer?.cancel());
    Future.microtask(_load);
    return const GameLockState.unknown();
  }

  Future<void> _load() async {
    final result = await _repository.listByGame(gameId);
    result.match(
      (failure) {
        state = GameLockState(
          status: GameLockStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        _schedules = items.where((s) => s.isActive).toList();
        _timer?.cancel();
        _timer = Timer.periodic(_tickInterval, (_) => _recompute());
        _recompute();
      },
    );
  }

  void _recompute() {
    final schedules = _schedules;
    if (schedules == null) return;
    if (schedules.isEmpty) {
      state = const GameLockState(status: GameLockStatus.noSchedules);
      return;
    }

    final now = DateTime.now();
    final windows = _buildWindows(schedules, now);

    for (final w in windows) {
      if (now.isBefore(w.lockStart)) {
        state = GameLockState(
          status: GameLockStatus.open,
          nextDrawAt: w.drawAt,
          nextCutoffMinutes: w.cutoffMinutes,
        );
        return;
      }
      if (!now.isAfter(w.lockEnd)) {
        final next = windows
            .where((x) => x.drawAt.isAfter(w.drawAt))
            .fold<_Window?>(null, (acc, x) => acc ?? x);
        state = GameLockState(
          status: GameLockStatus.locked,
          currentDrawAt: w.drawAt,
          currentCutoffMinutes: w.cutoffMinutes,
          reopenAt: w.lockEnd,
          nextDrawAt: next?.drawAt,
          nextCutoffMinutes: next?.cutoffMinutes,
        );
        return;
      }
    }

    state = const GameLockState(status: GameLockStatus.open);
  }

  List<_Window> _buildWindows(List<DrawSchedule> schedules, DateTime now) {
    final windows = <_Window>[];
    for (int offset = 0; offset <= 7; offset++) {
      final day = DateTime(now.year, now.month, now.day)
          .add(Duration(days: offset));
      final weekday = day.weekday % 7;
      for (final s in schedules) {
        if (!s.appliesTo(weekday)) continue;
        final t = s.parsedTime;
        final drawAt = DateTime(day.year, day.month, day.day, t.hour, t.minute);
        final lockStart =
            drawAt.subtract(Duration(minutes: s.cutoffMinutes));
        final lockEnd =
            drawAt.add(const Duration(minutes: _postDrawGraceMinutes));
        if (lockEnd.isBefore(now)) continue;
        windows.add(_Window(
          drawAt: drawAt,
          lockStart: lockStart,
          lockEnd: lockEnd,
          cutoffMinutes: s.cutoffMinutes,
        ));
      }
    }
    windows.sort((a, b) => a.drawAt.compareTo(b.drawAt));
    return windows;
  }
}

class _Window {
  const _Window({
    required this.drawAt,
    required this.lockStart,
    required this.lockEnd,
    required this.cutoffMinutes,
  });

  final DateTime drawAt;
  final DateTime lockStart;
  final DateTime lockEnd;
  final int cutoffMinutes;
}

final gameLockControllerProvider =
    NotifierProvider.family<GameLockController, GameLockState, String>(
  GameLockController.new,
);
