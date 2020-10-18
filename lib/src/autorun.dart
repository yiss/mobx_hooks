part of 'hooks.dart';

typedef AutorunFunction = void Function();

/// Runs the reaction immediately
/// and also on any change in the observables used inside
///
/// Useful for mutating the satet of an [Observable]
/// The following example is basic showcase for [useAutorun]
///
/// ```dart
/// class Counter extends ObserverHookWidget {
///   @override
///   Widget build(BuildContext context) {
///     final counter = Observable(0);
///     useAutorun(() {
///       counter.value++;
///     });
///
///     return Text('${counter.value}');
///   }
/// }
/// ```
void useAutorun(AutorunFunction fn, [List<Object> keys]) =>
    use(_AutorunHook(fn, keys));

class _AutorunHook extends Hook<void> {
  const _AutorunHook(this.fn, [List<Object> keys])
      : assert(fn != null, 'autorun function cannot be null'),
        super(keys: keys);
  final AutorunFunction fn;
  @override
  HookState<void, Hook<void>> createState() => _AutorunHookState();
}

class _AutorunHookState extends HookState<void, _AutorunHook> {
  ReactionDisposer disposer;

  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
    super.initHook();
    scheduleAutorun();
  }

  void scheduleAutorun() {
    disposer = autorun((_) => hook.fn());
  }

  @override
  void dispose() {
    if (disposer != null) {
      disposer();
    }
  }

  @override
  bool get debugSkipValue => true;

  @override
  String get debugLabel => 'useAutorun';
}
