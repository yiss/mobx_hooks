part of 'hooks.dart';

typedef ReactionFunction<T> = T Function();
typedef ReactionEffect<T> = void Function(T);

/// Runs the reaction immediately
/// and also on any change in the observables used inside
///
/// Useful for mutating the satet of an [Observable]
/// The following example is basic showcase for [useReaction]
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
void useReaction<T>(ReactionFunction<T> fn, ReactionEffect<T> effect,
        [List<Object> keys]) =>
    use(_ReactionHook<T>(fn, effect, keys));

class _ReactionHook<T> extends Hook<void> {
  const _ReactionHook(this.fn, this.effect, [List<Object> keys])
      : assert(fn != null, 'reaction function cannot be null'),
        assert(effect != null, 'effect function cannot be null'),
        super(keys: keys);

  final ReactionFunction<T> fn;
  final ReactionEffect<T> effect;

  @override
  HookState<void, Hook<void>> createState() => _ReactionHookState<T>();
}

class _ReactionHookState<T> extends HookState<void, _ReactionHook<T>> {
  ReactionDisposer disposer;

  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
    super.initHook();
    scheduleAutorun();
  }

  void scheduleAutorun() {
    disposer = reaction<T>((_) => hook.fn(), hook.effect);
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
  String get debugLabel => 'useReaction';
}
