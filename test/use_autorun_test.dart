import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_hooks/mobx_hooks.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('useAutorun debugFillProperties', (tester) async {
    final counter = Observable(0);
    final widget = ObserverHookBuilder(builder: (c) {
      useAutorun(() {
        counter.value++;
      });
      return const SizedBox();
    });

    await tester.pumpWidget(widget);
    final element = tester.element(find.byType(ObserverHookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      contains(
        'ObserverHookBuilder\n'
        ' │ useAutorun\n',
      ),
    );
  });
  testWidgets('useAutorun can mutate the state of an observable',
      (tester) async {
    final counter = Observable(0);
    final widget = ObserverHookBuilder(builder: (c) {
      useAutorun(() {
        counter.value++;
      });
      return Text(
        '${counter.value}',
        textDirection: TextDirection.ltr,
      );
    });

    await tester.pumpWidget(widget);
    expect(counter.value, 1);
  });

  testWidgets('HookObserverWidget will fail when useAutorun is null',
      (tester) async {
    Object exception;
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) => exception = details.exception;
    try {
      await tester.pumpWidget(ObserverHookBuilder(builder: (c) {
        useAutorun(null);
        return const SizedBox();
      }));
    } finally {
      FlutterError.onError = prevOnError;
    }
    // Assertion error caught by MobXException and builder method returns null
    expect(exception, isInstanceOf<FlutterError>());
    expect((exception as FlutterError).stackTrace, isNotNull);
  });

  testWidgets('autorun is immediately called', (tester) async {
    final autorunned = MockAutorun();
    final unrelated = MockWidgetBuild();
    List<Object> parameters;

    Widget builder() {
      return ObserverHookBuilder(builder: (context) {
        useAutorun(autorunned, parameters);
        unrelated();
        return Container();
      });
    }

    parameters = ['foo'];
    await tester.pumpWidget(builder());

    verify(autorunned()).called(1);
    verify(unrelated()).called(1);

    verifyNoMoreInteractions(autorunned);

    parameters = ['bar'];
    await tester.pumpWidget(builder());

    verify(autorunned()).called(1);
    verify(unrelated()).called(1);

    verifyNoMoreInteractions(autorunned);

    parameters = null;
    await tester.pumpWidget(builder());

    verify(autorunned()).called(1);
    verify(unrelated()).called(1);

    verifyNoMoreInteractions(autorunned);
  });

  testWidgets('autorun is called when an observable has changed',
      (tester) async {
    final autorunDispoerMock = MockAutorunDispoer<int>();
    final counter = Observable(0);
    final widget = ObserverHookBuilder(builder: (c) {
      useAutorun(() {
        autorunDispoerMock(counter.value);
      });
      return Container();
    });

    await tester.pumpWidget(widget);

    // useAutorun runs immediatly
    verify(autorunDispoerMock(0)).called(1);

    verifyNoMoreInteractions(autorunDispoerMock);

    runInAction(() {
      counter.value = 5;
    });

    await tester.pumpWidget(widget);

    verify(autorunDispoerMock(5)).called(1);
  });
}

class MockAutorun extends Mock {
  VoidCallback call();
}

class MockWidgetBuild extends Mock {
  void call();
}

class MockAutorunDispoer<T> extends Mock {
  void call(T value);
}
