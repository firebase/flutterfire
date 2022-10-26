// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key, required this.stories}) : super(key: key);

  final List<StoryWidget> stories;

  @override
  State<Stories> createState() => _StoriesState();
}

class _Category {
  _Category(this.title);

  final String title;
  final stories = <String, StoryWidget>{};
}

class _StoriesState extends State<Stories> {
  final _categories = <String, _Category>{};

  String? _activeCategoryTitle;
  String? _activeStoryTitle;

  StoryWidget? get activeStory {
    return _categories[_activeCategoryTitle]?.stories[_activeStoryTitle];
  }

  @override
  void initState() {
    _initializeCategories();
    super.initState();
  }

  void _initializeCategories() {
    for (final story in widget.stories) {
      final category = _categories.putIfAbsent(
        story.category,
        () => _Category(story.category),
      );
      category.stories[story.title] = story;
    }

    _activeCategoryTitle = _categories.keys.first;
    _activeStoryTitle = _categories[_activeCategoryTitle]!.stories.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 300,
            height: double.infinity,
            child: Card(
              child: ListView.builder(
                primary: false,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories.values.elementAt(index);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8).copyWith(left: 16),
                        child: Text(
                          category.title,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Column(
                        children: [
                          for (final story in category.stories.values)
                            ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(story.title),
                              ),
                              dense: true,
                              selected:
                                  _activeCategoryTitle == category.title &&
                                      story.title == _activeStoryTitle,
                              onTap: () {
                                setState(() {
                                  _activeCategoryTitle = category.title;
                                  _activeStoryTitle = story.title;
                                });
                              },
                            ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: activeStory ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class StoryScaffold extends StatelessWidget {
  const StoryScaffold({
    Key? key,
    this.knobs = const [],
    required this.child,
  }) : super(key: key);

  final Widget child;
  final List<Knob<Object?>> knobs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Navigator(
            onPopPage: (route, result) => false,
            pages: [
              MaterialPage(
                child: Center(child: child),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          height: double.infinity,
          child: Card(
            child: SingleChildScrollView(
              child: knobs.isNotEmpty
                  ? KnobsPanel(knobs: knobs)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class KnobsPanel extends StatefulWidget {
  const KnobsPanel({Key? key, required this.knobs}) : super(key: key);

  final List<Knob> knobs;

  @override
  // ignore: library_private_types_in_public_api
  _KnobsPanelState createState() => _KnobsPanelState();
}

class _KnobsPanelState extends State<KnobsPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final knob in widget.knobs)
          if (knob is Knob<bool>)
            BoolKnobControl(knob: knob)
          else if (knob is EnumKnob)
            EnumKnobControl(knob: knob)
      ],
    );
  }
}

class BoolKnobControl extends StatelessWidget {
  const BoolKnobControl({Key? key, required this.knob}) : super(key: key);

  final Knob<bool> knob;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(knob.title),
      value: knob.value,
      onChanged: (v) {
        knob.value = v!;
      },
    );
  }
}

class EnumKnobControl extends StatelessWidget {
  const EnumKnobControl({Key? key, required this.knob}) : super(key: key);

  final EnumKnob knob;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(knob.title),
          DropdownButton(
            items: [
              for (final e in knob.values)
                DropdownMenuItem(
                  value: e,
                  child: Text(e.toString().split('.').removeLast()),
                ),
            ],
            value: knob.value,
            onChanged: (v) {
              knob.value = v;
            },
          ),
        ],
      ),
    );
  }
}

abstract class Story {
  Widget get widget;
  String get category;
  String get title;

  List<Knob> get knobs;

  T knob<T>({required String title, required T value});

  T enumKnob<T>({
    required String title,
    required T value,
    required List<T> values,
  });

  void notify(String message);
}

abstract class StoryWidget extends StatelessWidget {
  const StoryWidget({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  final String category;
  final String title;

  @override
  Widget build(covariant StoryElement context);

  @override
  StatelessElement createElement() => StoryElement(this);
}

class Knob<T> extends ValueNotifier<T> {
  Knob(this.title, T value) : super(value);

  final String title;

  void subscribe(StoryElement element) {
    addListener(() {
      element.markNeedsBuild();
    });
  }
}

class MultiValueKnob<T> extends Knob<T> {
  MultiValueKnob(String title, T value, this.values) : super(title, value);

  final List<T> values;
}

class EnumKnob<T> extends MultiValueKnob<T> {
  EnumKnob(String title, value, List<T> values) : super(title, value, values);
}

final _widgetKnobs = <int, List<Knob>>{};

class StoryElement extends StatelessElement implements Story {
  StoryElement(StoryWidget widget) : super(widget);

  @override
  StoryWidget get widget => super.widget as StoryWidget;

  @override
  String get category => widget.category;
  @override
  String get title => widget.title;

  @override
  final List<Knob> knobs = [];
  final Map<String, Knob> knobsMap = {};

  @override
  T knob<T>({required String title, required T value}) {
    return _knob(title: title, knob: Knob<T>(title, value));
  }

  @override
  T enumKnob<T>({
    required String title,
    required T value,
    required List<T> values,
  }) {
    return _knob(title: title, knob: EnumKnob<T>(title, value, values));
  }

  T _knob<T>({required String title, required Knob knob}) {
    if (knobsMap.containsKey(title)) {
      return knobsMap[title]!.value;
    } else {
      knobsMap[title] = knob;
      knobs.add(knob);
      knob.subscribe(this);
      return knob.value;
    }
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    if (_widgetKnobs.containsKey(widget.hashCode)) {
      knobs.addAll(_widgetKnobs[widget.hashCode]!);
      _widgetKnobs[widget.hashCode]!.forEach((element) {
        knobsMap[element.title] = element;
      });

      knobs.forEach((element) {
        element.subscribe(this);
      });
    }

    super.mount(parent, newSlot);
  }

  @override
  void notify(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build() {
    // Make sure to call "build" before building StoryScaffold
    // as the list of "knobs" is obtained by tracking the "build" call
    final child = super.build();

    if (knobs.isEmpty) return child;

    return StoryScaffold(
      knobs: knobs,
      child: child,
    );
  }
}
