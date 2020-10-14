import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx_hooks/src/internal.dart';
import 'package:mobx/mobx.dart';

import 'package:mobx_hooks/mobx_hooks.dart';

class InitialHookWidget extends ObserverHookWidget {
  const InitialHookWidget(this.observable, {Key key, this.name})
      : super(key: key, name: name);
  final String name;
  final Observable observable;
  @override
  Widget build(BuildContext context) {
    final value = observable.value as int;
    return Text(
      '$value',
      textDirection: TextDirection.ltr,
    );
  }
}

class InitialHookStatefulWidget extends StatefulObserverHookWidget {
  const InitialHookStatefulWidget(this.observable, {Key key}) : super(key: key);

  final Observable observable;

  @override
  State<StatefulWidget> createState() => InitialHookStatefulWidgetState();

  @override
  String getName() => 'initial';
}

class InitialHookStatefulWidgetState extends State<InitialHookStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final value = widget.observable.value as int;
    return Text(
      '$value',
      textDirection: TextDirection.ltr,
    );
  }
}

void main() {
  testWidgets('ObserverHookWidget with name', (tester) async {
    final observable = Observable(0);
    final widgetBuilder = ObserverHookBuilder(builder: (_) {
      final value = observable.value;
      return Text(
        '$value',
        textDirection: TextDirection.ltr,
      );
    });
    await tester.pumpWidget(widgetBuilder);

    await tester.pump();

    final element = tester.element(find.byType(ObserverHookBuilder))
        as ObserverElementMixin;
    expect(element.reaction.name, startsWith('$widgetBuilder\n'));
    expect(element.reaction.name, contains(' main.<anonymous closure>'));
  });

  testWidgets("Release mode, the reaction's default name is widget.toString()",
      (tester) async {
    debugAddStackTraceInObserverNameForObserverHooksBuilder = false;
    addTearDown(
        () => debugAddStackTraceInObserverNameForObserverHooksBuilder = true);
    final observable = Observable(0);
    final widgetBuilder = ObserverHookBuilder(builder: (_) {
      final value = observable.value;
      return Text(
        '$value',
        textDirection: TextDirection.ltr,
      );
    });
    await tester.pumpWidget(widgetBuilder);

    final element =
        // ignore: avoid_as
        tester.element(find.byWidget(widgetBuilder)) as ObserverElementMixin;

    expect(element.reaction.name, equals('$widgetBuilder'));
  });

  testWidgets(
      'ObserverHookBuilder.debugFindConstructingStackFrame should return null if StackTrace empty',
      (tester) async {
    expect(
        ObserverHookBuilder.debugFindConstructingStackFrame(StackTrace.empty),
        null);
  });

  testWidgets('StatefulHookWidget test with Observable ', (tester) async {
    final observable = Observable(0);
    final intialWidget = InitialHookStatefulWidget(observable);
    await tester.pumpWidget(intialWidget);
    final widget = tester.widget(find.byType(InitialHookStatefulWidget))
        as ObserverWidgetMixin;

    expect(widget != null, true);
    expect(widget.getName(), 'initial');
  });

  testWidgets('ObserverHookWidget should throw exception when builder is null',
      (tester) async {
    expect(() => ObserverHookBuilder(builder: null),
        throwsA(isInstanceOf<AssertionError>()));
  });
}
