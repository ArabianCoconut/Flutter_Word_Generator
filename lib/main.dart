import 'dart:developer';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    _notifyListeners();
  }

  var favorites = <WordPair>{};
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    _notifyListeners();
  }

  void deleteFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      //remove last item in the list
      favorites.remove(favorites.last);
    }
    _notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }
}

// ...

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const Favorites();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constrains.maxWidth > 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  log('selected: $value');
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    String text = 'You have ${appState.favorites.length} favorites:';

    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(text)),
        for (var pair in favorites)
          ListTileTheme(
            child: ListTile(
              subtitle: FavoritesCard(pair: pair),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  appState.deleteFavorites();
                },
              ),
            ),
          )
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return CardSet(
        theme: theme,
        pair: pair,
        style: style,
        alignment: MainAxisAlignment.center);
  }
}

class FavoritesCard extends StatelessWidget {
  const FavoritesCard({super.key, required this.pair});
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return CardSet(
        theme: theme,
        pair: pair,
        style: style,
        alignment: MainAxisAlignment.start);
  }
}

class CardSet extends StatelessWidget {
  const CardSet(
      {super.key,
      required this.theme,
      required this.pair,
      required this.style,
      required this.alignment});

  final ThemeData theme;
  final WordPair pair;
  final TextStyle style;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: alignment,
          children: [
            Card(
              color: theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  pair.asLowerCase,
                  style: style,
                  semanticsLabel: "${pair.first} ${pair.second}",
                ),
              ),
            )
          ],
        )
      ],
    ));
  }
}
