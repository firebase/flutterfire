// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// Uncomment this line after running flutterfire configure
// import 'firebase_options.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/firebase_options.dart';
import 'package:firebase_data_connect_example/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'generated/movies.dart';

const appCheckEnabled = false;
const configureEmulator = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (appCheckEnabled) {
    await FirebaseAppCheck.instance.activate(
      // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
      // argument for `webProvider`
      providerWeb: ReCaptchaV3Provider('your-site-key'),
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      providerAndroid: const AndroidDebugProvider(),
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Device Check provider
      // 3. App Attest provider
      // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
      providerApple: const AppleAppAttestProvider(),
    );
  }
  if (configureEmulator) {
    MoviesConnector.instance.dataConnect
        .useDataConnectEmulator('127.0.0.1', 9399);
    FirebaseAuth.instance.useAuthEmulator(
      'localhost',
      9099,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DataConnect Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Center(
        child: DataConnectWidget(),
      ),
    );
  }
}

class DataConnectWidget extends StatefulWidget {
  const DataConnectWidget({super.key});
  @override
  State<DataConnectWidget> createState() => _DataConnectWidgetState();
}

class _DataConnectWidgetState extends State<DataConnectWidget> {
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime _releaseYearDate = DateTime(1920);
  List<ListMoviesMovies> _movies = [];
  double _rating = 0;

  Future<void> triggerReload() async {
    QueryRef ref = MoviesConnector.instance.listMovies().ref();
    ref.execute();
  }

  @override
  void initState() {
    super.initState();

    QueryRef<ListMoviesData, void> ref =
        MoviesConnector.instance.listMovies().ref();

    ref.subscribe().listen((event) {
      setState(() {
        _movies = event.data.movies;
      });
    }).onError((e) {
      _showError("Got an error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flex(direction: Axis.vertical, children: [
          Flexible(
            flex: 1,
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
              controller: _titleController,
            ),
          ),
          Flexible(
              flex: 1,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Genre',
                ),
                controller: _genreController,
              )),
          Flexible(
              flex: 1,
              child: RatingBar.builder(
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
              )),
          Flexible(
              flex: 1,
              child: YearPicker(
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                selectedDate: _releaseYearDate,
                onChanged: (value) {
                  setState(() {
                    _releaseYearDate = value;
                  });
                },
              )),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async {
              await MoviesConnector.instance.thing().execute();
              String title = _titleController.text;
              String genre = _genreController.text;
              if (title == '' || genre == '') {
                return;
              }

              MutationRef ref = MoviesConnector.instance
                  .createMovie(
                    title: title,
                    releaseYear: _releaseYearDate.year,
                    genre: genre,
                  )
                  .rating(_rating)
                  .ref();
              try {
                await ref.execute();
                triggerReload();
              } catch (e) {
                _showError("unable to create a movie: $e");
              }
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
