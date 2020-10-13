import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobx/mobx.dart';

/// Subscribes to an [Observable] and return it's value
/// The following example is basic counter application
/// ```dart
/// class Counter extends HookWidget {
///   @override
///   Widget build(BuildContext context) {
///     final counter = Observable(0);
///     final value = useObservable(counterObservabe);
///
///     return GestureDetector(
///       // automatically triggers a rebuild of Counter widget
///       onTap: () => counter.value++,
///       child: Text('$value'),
///     );
///   }
/// }
/// ```
T useObservable<T>(Observable<T> observable) =>
    use(_ObservableHook(observable));

class _ObservableHook<T> extends Hook<T> {
  const _ObservableHook(this._observable);

  final Observable<T> _observable;

  @override
  HookState<T, Hook<T>> createState() => _ObservableHookState();
}

class _ObservableHookState<T> extends HookState<T, _ObservableHook<T>> {
  T _value;

  @override
  T build(BuildContext context) => _value;

  @override
  void initHook() {
    super.initHook();
    hook._observable.observe(_listener, fireImmediately: true);
  }

  void _listener(ChangeNotification<T> notification) {
    setState(() {
      _value = notification.newValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Object get debugValue => _value;

  @override
  String get debugLabel => 'useObservable<$T>';
}
