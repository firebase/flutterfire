import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class Stories extends StatefulWidget {
  final List<StoryWidget> stories;
  const Stories({Key? key, required this.stories}) : super(key: key);

  @override
  State<Stories> createState() => _StoriesState();
}

class Category {
  final String title;
  final List<Story> stories;

  final Set<String> _storyIds = {};

  Category(this.title, this.stories);

  void addStory(Story story) {
    if (_storyIds.contains(story.title)) return;
    stories.add(story);
    _storyIds.add(story.title);
  }
}

class _StoriesState extends State<Stories> {
  final List<Category> _categories = [];
  Map<String, Category> _categoriesMap = {};

  int _activeCategoryIndex = 0;
  int _activeStoryIndex = 0;

  Story? get activeStory {
    if (_categories.length < _activeCategoryIndex + 1) return null;
    final category = _categories[_activeCategoryIndex];

    if (category.stories.length < _activeStoryIndex + 1) return null;
    return category.stories[_activeStoryIndex];
  }

  void registerStory(Story story) {
    if (!_categoriesMap.containsKey(story.category)) {
      final category = Category(story.category, []);
      _categoriesMap[story.category] = category;
      _categories.add(category);
      category.addStory(story);
    } else {
      _categoriesMap[story.category]!.addStory(story);
    }
  }

  @override
  void initState() {
    widget.stories.forEach((w) {
      final el = w.createElement();
      el.build();
      (el as StoryElement)._register(this);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 300,
            height: mq.size.height,
            child: Card(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];

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
                          for (int i = 0; i < category.stories.length; i++)
                            ListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(category.stories[i].title),
                              ),
                              dense: true,
                              selected: i == _activeStoryIndex &&
                                  index == _activeCategoryIndex,
                              onTap: () {
                                setState(() {
                                  _activeCategoryIndex = index;
                                  _activeStoryIndex = i;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Offstage(
                      child: Row(
                        children: [
                          for (int i = 0; i < widget.stories.length; i++)
                            SizedBox(
                              width: constraints.biggest.width,
                              height: constraints.biggest.height,
                              child: widget.stories[i],
                            )
                        ],
                      ),
                    ),
                    Navigator(
                      key: ValueKey(activeStory.hashCode),
                      onPopPage: (route, result) {
                        return false;
                      },
                      pages: [
                        MaterialPage(
                          child: Center(
                            child:
                                activeStory?.widget ?? const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: 300,
            height: mq.size.height,
            child: Card(
              child: SingleChildScrollView(
                child: activeStory != null && activeStory!.knobs.isNotEmpty
                    ? KnobsPanel(knobs: activeStory!.knobs)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KnobsPanel extends StatefulWidget {
  final List<Knob> knobs;
  const KnobsPanel({Key? key, required this.knobs}) : super(key: key);

  @override
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
  final Knob<bool> knob;
  const BoolKnobControl({Key? key, required this.knob}) : super(key: key);

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
  final EnumKnob knob;
  const EnumKnobControl({Key? key, required this.knob}) : super(key: key);

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
  set category(String category);

  String get title;
  set title(String title);

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
  const StoryWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() {
    return StoryElement(this);
  }

  @override
  Widget build(BuildContext context);

  Story storyOf(BuildContext context) => context as Story;
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
  final List<T> values;
  MultiValueKnob(String title, T value, this.values) : super(title, value);
}

class EnumKnob<T> extends MultiValueKnob<T> {
  EnumKnob(String title, value, List<T> values) : super(title, value, values);
}

final _widgetKnobs = <int, List<Knob>>{};

class StoryElement extends StatelessElement implements Story {
  StoryElement(StatelessWidget widget) : super(widget);

  @override
  late String category;
  @override
  late String title;

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

  void _register(_StoriesState state) {
    _widgetKnobs[widget.hashCode] = knobs;
    state.registerStory(this);
  }

  @override
  Widget build() {
    return (widget as StoryWidget).build(this);
  }
}
