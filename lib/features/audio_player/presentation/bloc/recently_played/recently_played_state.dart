import 'package:equatable/equatable.dart';

class RingtoneState extends Equatable {
  final bool loading;
  final double duration;
  final double start;
  final double end;
  final bool trimming;

  const RingtoneState({
    this.loading = true,
    this.duration = 0,
    this.start = 0,
    this.end = 0,
    this.trimming = false,
  });

  RingtoneState copyWith({
    bool? loading,
    double? duration,
    double? start,
    double? end,
    bool? trimming,
  }) {
    return RingtoneState(
      loading: loading ?? this.loading,
      duration: duration ?? this.duration,
      start: start ?? this.start,
      end: end ?? this.end,
      trimming: trimming ?? this.trimming,
    );
  }

  @override
  List<Object?> get props => [loading, duration, start, end, trimming];
}
