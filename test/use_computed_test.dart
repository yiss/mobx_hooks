import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import 'package:mobx_hooks/mobx_hooks.dart';

void main() {
  testWidgets('useComputed debugFillProperties', (tester) async {
    final observable = Observable(0);
    final computed = Computed(() => observable.value.isEven);
    await tester.pumpWidget(
      HookBuilder(builder: (context) {
        useComputed(computed);
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
        ' │ useComputed<bool>: true\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n',
      ),
    );
  });

  testWidgets('useComputed value changes when change observable',
      (tester) async {
    final counter = Observable(0);
    final counterParity = Computed(() => counter.value.isEven);
    bool parityCheck;
    var buildCount = 0;

    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        buildCount++;
        parityCheck = useComputed(counterParity);
        return Container();
      },
    ));
    expect(counter.value, 0);
    expect(counterParity.value, true);
    expect(parityCheck, true);
    expect(buildCount, 1);

    runInAction(() => counter.value = 7);
    await tester.pump();
    expect(counter.value, 7);
    expect(counterParity.value, false);
    expect(buildCount, 2);
  });

  testWidgets('useComputed triggers rebuild', (tester) async {
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
