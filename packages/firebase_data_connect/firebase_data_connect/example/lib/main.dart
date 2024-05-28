import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(const MyApp());
}

class AddMovie implements DataConnectClass {
  AddMovie(this.title, this.genre, this.rating);
  String title;
  String genre;
  double rating;
  @override
  toJson() {
    // return '{"title"}';
    return jsonEncode({'title': title, 'genre': genre, 'rating': rating});
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DataConnect Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Data Connect Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class DataConnectWidget extends StatefulWidget {
  const DataConnectWidget({super.key});
  @override
  State<DataConnectWidget> createState() => _DataConnectWidgetState();
}

class ListMoviesResponse extends DataConnectClass {
  late List<Movie> movies;
  static fromRealJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    final parsed = (data['movies'] as List).cast<Map<String, dynamic>>();
    ListMoviesResponse response = new ListMoviesResponse();
    response.movies =
        parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
    return response;
  }

  @override
  fromJson(String json) {
    // TODO: implement fromJson
    Map<String, dynamic> data = jsonDecode(json);
    final parsed = (data['movies'] as List).cast<Map<String, dynamic>>();
    movies = parsed.map<Movie>((json) => Movie.fromJson(json)).toList();
    return this;
  }

  @override
  String toJson() {
    return jsonEncode(this);
  }
}

class Movie {
  final String title;
  final String genre;
  final String id;
  final double rating;
  Movie(
      {required this.title,
      required this.genre,
      required this.id,
      required this.rating});
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
        genre: json['genre'] as String,
        id: json['id'] as String,
        rating: json['rating'] as double,
        title: json['title'] as String);
  }
}

ListMoviesResponse serializer(String json) {
  return ListMoviesResponse.fromRealJson(json);
}

class AddMovieResponse implements DataConnectClass {
  AddMovieResponse(this.movie_insert) {}
  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  String movie_insert;
  static fromRealJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return AddMovieResponse(map['movie_insert']['id']);
  }
}

AddMovieResponse addMovieSerializer(String json) {
  return AddMovieResponse.fromRealJson(json);
}

class EmptyDataConnectClass<T> extends DataConnectClass<T> {
  @override
  fromJson(String json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  String toJson() {
    // TODO: implement toJson
    return '';
  }
}

class _DataConnectWidgetState extends State<DataConnectWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  List<Movie> _movies = [];
  double _rating = 0;

  Future<void> triggerReload() async {
    QueryRef<ListMoviesResponse, EmptyDataConnectClass> ref =
        FirebaseDataConnect.instance
            .query<ListMoviesResponse, EmptyDataConnectClass>(
                "listMovies", serializer, EmptyDataConnectClass());

    ref.execute();
  }

  @override
  void initState() {
    super.initState();
    initFirebase().then((value) {
      FirebaseDataConnect.instanceFor(
          app: Firebase.app(),
          connectorConfig:
              ConnectorConfig("us-central1", "movies", "dataconnect"));
      String host = 'localhost';
      try {
        if (Platform.isAndroid) {
          host = '10.0.2.2';
        }
      } catch (_) {
        print("Ignoring");
      }
      print(host);
      int port = kIsWeb ? 9509 : 9510;
      FirebaseDataConnect.instance.useDataConnectEmulator(host, port, false);
      QueryRef<ListMoviesResponse, EmptyDataConnectClass> ref =
          FirebaseDataConnect.instance
              .query<ListMoviesResponse, EmptyDataConnectClass>(
                  "listMovies", serializer, EmptyDataConnectClass());
      ref.subscribe().listen((event) {
        setState(() {
          _movies = event.movies;
        });
      });
      triggerReload();
    });
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flex(direction: Axis.vertical, children: [
          // Flexible(
          // child: Padding(
          // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Name',
            ),
            controller: _titleController,
          ),
          // Flexible(
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Genre',
            ),
            controller: _genreController,
          ),
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              _rating = rating;
            },
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              String title = _titleController.text;
              String genre = _genreController.text;
              if (title == '' || genre == '') {
                return;
              }
              AddMovie newData = AddMovie(title, genre, _rating);
              FirebaseDataConnect.instanceFor(
                  app: Firebase.app(),
                  connectorConfig:
                      ConnectorConfig("us-central1", "movies", "dataconnect"));
              MutationRef<AddMovieResponse, AddMovie> ref = FirebaseDataConnect
                  .instance
                  .mutation("addMovie", addMovieSerializer, newData);
              ref.execute().then((res) {
                triggerReload();
              });
            },
            child: const Text('Add Movie'),
          ),

          const Center(
            child: Text(
              "Movies",
              style: TextStyle(fontSize: 35.0),
            ),
          ),

          Expanded(
              child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => triggerReload(),
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      children: _movies
                          .map((movie) => Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Center(
                                  child: Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )))
                          .toList()),
                ),
              )
            ],
          ))
        ]));
  }

  _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: const Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.

        child: DataConnectWidget(),
      ),
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
