import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import 'package:mobx_hooks/mobx_hooks.dart';

void main() {
  testWidgets('useCompute debugFillProperties', (tester) async {
    final observable = Observable(0);
    await tester.pumpWidget(
      HookBuilder(builder: (context) {
        useCompute(() {
          return observable.value.isEven;
        }, [observable]);
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
        ' │ useCompute<bool>: Computed<bool>(true)\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n',
      ),
    );
  });

  testWidgets('useCompute compute value from', (tester) async {
    final firstName = Observable('Serena');
    final lastName = Observable('Williams');
    Computed<String> fullName;
    var buildCount = 0;

    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        buildCount++;
        fullName = useCompute(() {
          return '${firstName.value} ${lastName.value}';
        });
        return Container();
      },
    ));
    expect(firstName.value, 'Serena');
    expect(lastName.value, 'Williams');
    expect(fullName.value, 'Serena Williams');

    firstName.value = 'Venus';
    await tester.pump();
    expect(firstName.value, 'Venus');
    expect(lastName.value, 'Williams');
    expect(fullName.value, 'Venus Williams');
    // Make sure the change doesnt trigger rebuild
    expect(buildCount, 1);
  });

  testWidgets('useCompute raise error when compute function is null',
      (tester) async {
    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        useCompute<String>(null, const []);
        return Container();
      },
    ));

    expect(tester.takeException(), isAssertionError);
  });
}
