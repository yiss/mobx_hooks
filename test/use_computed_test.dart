import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import 'package:mobx_hooks/mobx_hooks.dart';

void main() {
  testWidgets('useComputed debugFillProperties', (tester) async {
    final observable = Observable(0);
    await tester.pumpWidget(
      ObserverHookBuilder(builder: (context) {
        useComputed(() {
          return observable.value.isEven;
        }, [observable]);
        return const SizedBox();
      }),
    );

    await tester.pump();

    final element = tester.element(find.byType(ObserverHookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      equalsIgnoringHashCodes(
        'ObserverHookBuilder\n'
        ' │ useComputed<bool>: Computed<bool>(true)\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n',
      ),
    );
  });

  testWidgets('useComputed compute value from', (tester) async {
    final firstName = Observable('Serena');
    final lastName = Observable('Williams');
    Computed<String> fullName;
    var buildCount = 0;

    await tester.pumpWidget(ObserverHookBuilder(
      builder: (context) {
        buildCount++;
        fullName = useComputed(() {
          return '${firstName.value} ${lastName.value}';
        });
        return Container();
      },
    ));
    expect(firstName.value, 'Serena');
    expect(lastName.value, 'Williams');
    expect(fullName.value, 'Serena Williams');

    runInAction(() {
      firstName.value = 'Venus';
    });
    
    await tester.pump();
    expect(firstName.value, 'Venus');
    expect(lastName.value, 'Williams');
    expect(fullName.value, 'Venus Williams');
    // Make sure the change doesnt trigger rebuild
    expect(buildCount, 1);
  });

  testWidgets('useComputed raise error when compute function is null',
      (tester) async {
    // Use HookBuilder because we don't have any Observables
    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        useComputed<String>(null);
        return Container();
      },
    ));
    expect(tester.takeException(), isAssertionError);
  });
}
