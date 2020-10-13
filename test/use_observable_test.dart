import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import 'package:mobx_hooks/mobx_hooks.dart';

void main() {
  testWidgets('debugFillProperties', (tester) async {
    final observable = Observable(0);

    await tester.pumpWidget(
      HookBuilder(builder: (context) {
        useObservable(observable);
        return const SizedBox();
      }),
    );

    await tester.pump();

    final element = tester.element(find.byType(HookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      equalsIgnoringHashCodes(
        'HookBuilder\n'
        ' │ useObservable<int>: 0\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#15a0f)\n',
      ),
    );
  });

  testWidgets('useObservable return value of observable after update',
      (tester) async {
    final counter = Observable(1);
    var counterValue = 0;
    Widget Function(BuildContext) builder(Observable<int> observable) {
      return (context) {
        counterValue = useObservable(observable);
        return Container();
      };
    }

    await tester.pumpWidget(HookBuilder(builder: builder(counter)));
    expect(counterValue, 1);

    counter.value = 8;
    await tester.pumpWidget(HookBuilder(builder: builder(counter)));
    expect(counterValue, 8);
  });

  testWidgets('useObservable triggers rebuild', (tester) async {
    var buildCount = 0;
    final counter = Observable(1);
    var counterValue = 0;
    Widget Function(BuildContext) builder(Observable<int> observable) {
      return (context) {
        buildCount++;
        counterValue = useObservable(observable);
        return Container();
      };
    }

    await tester.pumpWidget(HookBuilder(builder: builder(counter)));
    expect(counterValue, 1);

    counter.value = 8;
    await tester.pumpWidget(HookBuilder(builder: builder(counter)));
    expect(counterValue, 8);
    expect(buildCount, 2);
  });
}
