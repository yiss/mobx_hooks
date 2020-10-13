import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobx/mobx.dart';

typedef ComputeFunction<T> = T Function();

/// Genrates a [Computed<T>] value from a function
/// This allows to have granular
/// useful for computing derived state from other observable without triggerig a rebuild
///
/// The following example is basic showcase for [useCompute]
///
/// ```dart
/// class Name extends HookWidget {
///   @override
///   Widget build(BuildContext context) {
///     final firstName = Observable('Serena');
///     final lastName = Observable('Williams');
///     final fullName = useCompute(() {
///       return '$firstName $lastName';
///     });
///
///     return GestureDetector(
///       // automatically triggers a rebuild of Counter widget
///       onTap: () => counter.value++,
///       child: Text('${}'),
///     );
///   }
/// }
/// ```
Computed<T> useCompute<T>(ComputeFunction<T> fn, [List<Object> keys]) =>
    use(_ComputeHook(fn, keys));

/// Subscribes to [Computed<T>] and returns it's value
/// This will trigger the build method to be called everytime the value of the computed is changed
T useComputed<T>(Computed<T> computed) => use(_ComputedHook<T>(computed));

class _ComputeHook<T> extends Hook<Computed<T>> {
  const _ComputeHook(this.fn, [List<Object> keys])
      : assert(fn != null, 'computed function cannot be null'),
        super(keys: keys);
  final ComputeFunction<T> fn;
  @override
  HookState<Computed<T>, Hook<Computed<T>>> createState() =>
      _ComputeHookState();
}

class _ComputeHookState<T> extends HookState<Computed<T>, _ComputeHook<T>> {
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
  String get debugLabel => 'useCompute<$T>';
}

class _ComputedHook<T> extends Hook<T> {
  const _ComputedHook(this._computed);
  final Computed<T> _computed;

  @override
  HookState<T, Hook<T>> createState() => _ComputedHookState();
}

class _ComputedHookState<T> extends HookState<T, _ComputedHook<T>> {
  T _value;
  @override
  T build(BuildContext context) => _value;

  @override
  void initHook() {
    super.initHook();
    hook._computed.observe(_computedListener);
  }

  void _computedListener(ChangeNotification<T> notification) {
    setState(() {
      _value = notification.newValue;
    });
  }

  @override
  Object get debugValue => _value;

  @override
  String get debugLabel => 'useComputed<$T>';
}
