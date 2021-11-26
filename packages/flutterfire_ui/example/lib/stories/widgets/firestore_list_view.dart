import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui_example/stories/stories_lib/story.dart';

class Country {
  Country({required this.towns});
  Country.fromJson(Map<String, Object?> json)
      : this(
          towns: (json['towns']! as List).map((e) => Town.fromJson(e)).toList(),
        );

  final List<Town> towns;

  Map<String, Object?> toJson() {
    return {
      'towns': towns.map((e) => e.toJson()).toList(),
    };
  }
}

class Town {
  Town({required this.name, required this.mayor, required this.population});
  Town.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          mayor: json['mayor']! as String,
          population: json['population']! as int,
        );

  final String name;
  final String mayor;
  final int population;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'mayor': mayor,
      'population': population,
    };
  }
}

final countriesCollection = FirebaseFirestore.instance
    .collection('firebasePerfTest')
    .withConverter<Country>(
      fromFirestore: (snapshot, _) => Country.fromJson(snapshot.data()!),
      toFirestore: (country, _) => country.toJson(),
    );

class FirestoreListViewStory extends StoryWidget {
  const FirestoreListViewStory({Key? key})
      : super(key: key, category: 'Widgets', title: 'FirestoreListView');

  @override
  Widget build(StoryElement context) {
    return FirestoreListView<Country>(
      query: countriesCollection,
      primary: true,
      itemBuilder: (context, snapshot) {
        return Column(
          children: [
            for (final town in snapshot.data().towns)
              Text('${town.name} (${town.population})'),
          ],
        );
      },
    );
  }
}
