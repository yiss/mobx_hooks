part of 'hooks.dart';

typedef ComputeFunction<T> = T Function();

/// Genrates a [Computed<T>] value from a function
/// This allows to have granular
/// useful for computing derived state from other observable without triggerig a rebuild
///
/// The following example is basic showcase for [useComputed]
///
/// ```dart
/// class Counter extends HookWidget {
///   @override
///   Widget build(BuildContext context) {
///     final counter = Observable(0);
///     final parity = useComputed(() {
///       return counter.value.isEven;
///     });
///
///     return GestureDetector(
///       // automatically triggers a rebuild of Counter widget
///       onTap: () => counter.value++,
///       child: Text('${parity.value}'),
///     );
///   }
/// }
/// ```
Computed<T> useComputed<T>(ComputeFunction<T> fn, [List<Object> keys]) =>
    use(_ComputedHook(fn, keys));

class _ComputedHook<T> extends Hook<Computed<T>> {
  const _ComputedHook(this.fn, [List<Object> keys])
      : assert(fn != null, 'computed function cannot be null'),
        super(keys: keys);
  final ComputeFunction<T> fn;
  @override
  HookState<Computed<T>, Hook<Computed<T>>> createState() =>
      _ComputedHookState();
}

class _ComputedHookState<T> extends HookState<Computed<T>, _ComputedHook<T>> {
  Computed<T> _computed;

  @override
  Computed<T> build(BuildContext context) => _computed;

  @override
  void initHook() {
    super.initHook();
    _computed = Computed(hook.fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Object get debugValue => 'Computed<$T>(${_computed.value})';

  @override
  String get debugLabel => 'useComputed<$T>';
}
