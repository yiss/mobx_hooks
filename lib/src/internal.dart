import 'package:flutter/widgets.dart';
// ignore: implementation_imports, invalid_use_of_visible_for_testing_member
import 'package:flutter_hooks/src/framework.dart' show HookElement;
import 'package:flutter_mobx/flutter_mobx.dart';

/// A [Widget] that can use Hook
///
/// It's usage is very similar to [StatelessWidget].
/// [ObserverHookWidget] do not have any life-cycle and implements
/// only a [build] method.
///
/// The difference is that it can use [Hook], which allows
/// [ObserverHookWidget] to store mutable data without implementing a [State].
abstract class ObserverHookWidget extends StatelessWidget
    with ObserverWidgetMixin {
  /// Initializes [key] for subclasses.
  const ObserverHookWidget({Key key, String name})
      : _name = name,
        super(key: key);

  final String _name;

  @override
  _StatelessObserverHookElement createElement() =>
      _StatelessObserverHookElement(this);

  @override
  String getName() => _name ?? '$this';
}

class _StatelessObserverHookElement extends StatelessElement
    // ignore: invalid_use_of_visible_for_testing_member
    with
        HookElement,
        ObserverElementMixin {
  _StatelessObserverHookElement(ObserverHookWidget hooks) : super(hooks);
}

/// A [StatefulWidget] that can use [Hook]
///
/// It's usage is very similar to [StatefulWidget], but use hooks inside [State.build].
///
/// The difference is that it can use [Hook], which allows
/// [ObserverHookWidget] to store mutable data without implementing a [State].
abstract class StatefulObserverHookWidget extends StatefulWidget
    with ObserverWidgetMixin {
  /// Initializes [key] for subclasses.
  const StatefulObserverHookWidget({Key key}) : super(key: key);

  @override
  _StatefulObserverHookElement createElement() =>
      _StatefulObserverHookElement(this);
}

class _StatefulObserverHookElement extends StatefulElement
    with HookElement, ObserverElementMixin {
  _StatefulObserverHookElement(StatefulObserverHookWidget hooks) : super(hooks);
}

/// A [ObserverHookWidget] that defer its `build` to a callback
class ObserverHookBuilder extends ObserverHookWidget {
  /// Creates a widget that delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const ObserverHookBuilder({
    @required this.builder,
    Key key,
  })  : assert(builder != null, '`builder` cannot be null'),
        super(key: key);

  /// The callback used by [ObserverHookBuilder] to create a widget.
  ///
  /// If a [Hook] asks for a rebuild, [builder] will be called again.
  /// [builder] must not return `null`.
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
