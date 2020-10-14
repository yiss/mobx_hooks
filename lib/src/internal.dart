import 'dart:convert';

import 'package:flutter/widgets.dart';
// ignore: implementation_imports, invalid_use_of_visible_for_testing_member
import 'package:flutter_hooks/src/framework.dart' show HookElement;
import 'package:flutter_mobx/flutter_mobx.dart';

/// `true` if a stack frame indicating where an [Observer] was created should be
/// included in its name. This is useful during debugging to identify the source
/// of warnings or errors.
///
/// Note that stack frames are only included in debug builds.
bool debugAddStackTraceInObserverNameForObserverHooksBuilder = true;

/// A [Widget] that can use Hook
///
/// It's usage is very similar to [StatelessWidget].
/// [ObserverHookWidget] do not have any life-cycle and implements
/// only a [build] method.
///
/// The difference is that it can use Hook, which allows
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
    with
        // ignore: invalid_use_of_visible_for_testing_member
        HookElement,
        ObserverElementMixin {
  _StatelessObserverHookElement(ObserverHookWidget hooks) : super(hooks);
}

/// A [StatefulWidget] that can use Hook
///
/// It's usage is very similar to [StatefulWidget], but use hooks inside [State.build].
///
/// The difference is that it can use Hook, which allows
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
    // ignore: invalid_use_of_visible_for_testing_member
    with
        HookElement,
        ObserverElementMixin {
  _StatefulObserverHookElement(StatefulObserverHookWidget hooks) : super(hooks);
}

/// A [ObserverHookWidget] that defer its `build` to a callback
class ObserverHookBuilder extends ObserverHookWidget {
  /// Creates a widget that delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  ObserverHookBuilder({
    @required this.builder,
    Key key,
  })  : assert(builder != null, '`builder` cannot be null'),
        debugConstructingStackFrame = debugFindConstructingStackFrame(),
        super(key: key);

  /// The callback used by [ObserverHookBuilder] to create a widget.
  ///
  /// If a Hook asks for a rebuild, [builder] will be called again.
  /// [builder] must not return `null`.
  final Widget Function(BuildContext context) builder;

  /// The stack frame pointing to the source that constructed this instance.
  final String debugConstructingStackFrame;

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  String getName() =>
      super.getName() +
      (debugConstructingStackFrame != null
          ? '\n$debugConstructingStackFrame'
          : '');

  static final _constructorStackFramePattern = RegExp(r'\bnew\b');

  @visibleForTesting
  // ignore: public_member_api_docs
  static String debugFindConstructingStackFrame([StackTrace stackTrace]) {
    String stackFrame;

    // ignore: prefer_asserts_with_message
    assert(() {
      if (debugAddStackTraceInObserverNameForObserverHooksBuilder) {
        final stackTraceString = (stackTrace ?? StackTrace.current).toString();
        stackFrame = LineSplitter.split(stackTraceString)
            // We are skipping frames representing:
            // 1. The anonymous function in the assert
            // 2. The debugFindConstructingStackFrame method
            // 3. The constructor invoking debugFindConstructingStackFrame
            //
            // The 4th frame is either user source (which is what we want), or
            // an Observer subclass' constructor (which we skip past with the
            // regex)
            .skip(3)
            // Search for the first non-constructor frame
            .firstWhere(
                (frame) => !_constructorStackFramePattern.hasMatch(frame),
                orElse: () => null);
      }
      return true;
    }());

    return stackFrame;
  }
}
