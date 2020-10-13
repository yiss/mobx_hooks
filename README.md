[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/) [![codecov](https://codecov.io/gh/yiss/mobx_hooks/branch/master/graph/badge.svg)](https://codecov.io/gh/yiss/mobx_hooks) ![Build](https://github.com/yiss/mobx_hooks/workflows/Build/badge.svg) [![pub package](https://img.shields.io/pub/v/mobx_hooks.svg)](https://pub.dartlang.org/packages/mobx_hooks)

<img src="https://github.com/yiss/mobx_hooks/raw/master/mobx_hooks.png" width="300">

# Mobx Hooks

Flutter Hooks for Mobx. This package attemp to bring [Flutter Hooks]() for [Mobx]()

## Motivation & Inspiration :

The motivation for this project started when I wanted to migrate an old project of mine from Mobx to Riverpod and Flutter Hooks. But as much as I enjoyed using Riverpod and Flutter Hooks, I missed the ease of use of Mobx. So as I looked for something that combines both, but I couldn't find any.

#### Inspirations :

This package was inspired and uses the following packages as dependecnies

- [Flutter Hooks](https://github.com/rrousselGit/flutter_hooks) by [Remi Ressoulet](https://github.com/rrousselGit)
- [MobX](https://mobx.netlify.app/)

## Getting Started :

Just add the dependency to mobx_hooks in your pubspec.yaml :

```yaml
dependecies:
  mobx_hooks: latest
```

## Example :

If you're familiar with MobX and Flutter Hooks, using MobX Hooks is very easy. Here is an example using a counter :

```dart
class Counter {
  Counter() {
    increment = Action(_increment);
  }

  final count = Observable(0);

  Action increment;

  void _increment() {
    _value.value++;
  }
}

final counter = Counter();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobX Hooks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage();

  @override
  Widget build(BuildContext context) {
    final count = useObservable(counter.count);
    return Scaffold(
      appBar: AppBar(
        title: Text('MobX Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
                '${count.value}',
                style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Hooks :

This is the initial list of Hooks available in this package. More are coming soon.

| Name              | Description                                                                                               |
| ----------------- | --------------------------------------------------------------------------------------------------------- |
| [useObservable]() | Subscribes to an [Observable](https://mobx.netlify.app/api/observable) and return it's value              |
| [useCompute]()    | Creates a Mobx [Computed](https://mobx.netlify.app/api/observable#computed) from the result of a function |
| [useComputed]()   | Subscribes to the value of a [Computed](https://mobx.netlify.app/api/observable#computed)                 |
