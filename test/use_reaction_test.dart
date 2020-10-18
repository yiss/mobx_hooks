import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart' hide when;
import 'package:mobx_hooks/mobx_hooks.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('useReaction debugFillProperties', (tester) async {
    final counter = Observable(0);
    final widget = ObserverHookBuilder(builder: (c) {
      useReaction<int>(() => counter.value, (value) => value.isEven);
      return const SizedBox();
    });

    await tester.pumpWidget(widget);
    final element = tester.element(find.byType(ObserverHookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      equalsIgnoringHashCodes('ObserverHookBuilder\n'
          ' │ useReaction\n'
          ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n'
          ''),
    );
  });

  testWidgets('useReaction calls only reaction at first', (tester) async {
    final counter = Observable(0);
    final reactionMock = MockReaction<int>();
    final reactionEffectMock = MockReactionEffect<int>();

    when(reactionMock(any)).thenReturn(0);

    final widget = ObserverHookBuilder(builder: (c) {
      useReaction<int>(() {
        reactionMock(counter.value);
        return counter.value;
      }, reactionEffectMock);
      return const SizedBox();
    });

    await tester.pumpWidget(widget);

    verify(reactionMock(any)).called(1);
    verifyZeroInteractions(reactionEffectMock);
    verifyNoMoreInteractions(reactionMock);
  });

  testWidgets('useReaction calls the reaction and effect', (tester) async {
    final counter = Observable(0);
    final reactionMock = MockReaction<int>();
    final reactionEffectMock = MockReactionEffect<int>();

    when(reactionMock(any)).thenReturn(0);

    final widget = ObserverHookBuilder(builder: (c) {
      useReaction<int>(() {
        reactionMock(counter.value);
        return counter.value;
      }, reactionEffectMock);
      return const SizedBox();
    });

    await tester.pumpWidget(widget);
    verify(reactionMock(any)).called(1);

    runInAction(() => counter.value++);
    await tester.pumpWidget(widget);
    verify(reactionEffectMock(1)).called(1);
  });

  testWidgets('HookObserverWidget will fail when useReaction reaction is null',
      (tester) async {
    Object exception;
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) => exception = details.exception;
    final reactionEffectMock = MockReactionEffect<int>();
    try {
      await tester.pumpWidget(ObserverHookBuilder(builder: (c) {
        useReaction<int>(null, reactionEffectMock);
        return const SizedBox();
      }));
    } finally {
      FlutterError.onError = prevOnError;
    }
    // Assertion error caught by MobXException and builder method returns null
    expect(exception, isInstanceOf<FlutterError>());
    expect((exception as FlutterError).stackTrace, isNotNull);
    verifyZeroInteractions(reactionEffectMock);
  });

  testWidgets('HookObserverWidget will fail when useReaction effect is null',
      (tester) async {
    Object exception;
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) => exception = details.exception;
    final reactionMock = MockReaction<int>();
    try {
      await tester.pumpWidget(ObserverHookBuilder(builder: (c) {
        useReaction<int>(() => reactionMock(0), null);
        return const SizedBox();
      }));
    } finally {
      FlutterError.onError = prevOnError;
    }
    // Assertion error caught by MobXException and builder method returns null
    expect(exception, isInstanceOf<FlutterError>());
    expect((exception as FlutterError).stackTrace, isNotNull);
    verifyZeroInteractions(reactionMock);
  });
}

class MockReaction<T> extends Mock {
  T call(T value);
}

class MockReactionEffect<T> extends Mock {
  void call(T value);
}
