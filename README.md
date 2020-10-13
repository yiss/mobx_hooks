<img src="mobx_hooks.png" width="300">

# Mobx Hooks

Flutter Hooks for Mobx. This package attemp to bring [Flutter Hooks]() for [Mobx]()

## Motivation :

The motivation for this project started when I wanted to migrate an old project of mine from Mobx to Riverpod and Flutter Hooks. But as much as I enjoyed using Riverpod and Flutter Hooks, I missed the ease of use of Mobx. So as I looked for something that combines both, but I couldn't find any.

## Getting Started :

Just add the dependency to mobx_hooks in your pubspec.yaml :

```yaml
dependecies:
  mobx_hooks: latest
```

## Exmaple :

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

// TODO
