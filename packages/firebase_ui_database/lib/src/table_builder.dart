// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'query_builder.dart';

/// {@template firebase_ui.database_table}
/// A [PaginatedDataTable] that is connected to Firestore.
///
/// The parameter [columnLabels] is required and is used to
/// - list the columns.
/// - give them a label.
/// - order the columns.
/// - let [FirebaseDatabaseDataTable] know what are the expected keys in a Firestore document.
///
/// An example usage would be:
///
/// ```dart
/// // A collection of {'name': string, 'age': number}
/// final usersCollection = FirebaseDatabase.instance.ref('users');
///
/// // ...
///
/// FirebaseDatabaseDataTable(
///   query: usersCollection,
///   columnLabels: {
///      'name': Text('User name'),
///      'age': Text('age'),
///   },
/// );
/// ```
/// {@endtemplate}
class FirebaseDatabaseDataTable extends StatefulWidget {
  /// {@macro firebase_ui.database_table}
  const FirebaseDatabaseDataTable({
    Key? key,
    required this.query,
    required this.columnLabels,
    this.header,
    this.onError,
    this.canDeleteItems = true,
    this.actions,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.onPageChanged,
    this.rowsPerPage = 10,
    this.dragStartBehavior = DragStartBehavior.start,
    this.arrowHeadColor,
    this.checkboxHorizontalMargin,
  })  : assert(
          columnLabels is LinkedHashMap,
          'only LinkedHashMap are supported as header',
        ), // using an assert instead of a type because `<A, B>{}` types as `Map` but is an instance of `LinkedHashMap`
        super(key: key);

  /// The firestore query that will be displayed
  final Query query;

  /// Whether documents can be removed from firestore using the table.
  final bool canDeleteItems;

  /// The columns and their labels based on the property name in Firestore
  final Map<String, Widget> columnLabels;

  /// When specified, will be called whenever an interaction with Firestore failed,
  /// when as when trying to delete an item without the proper rights.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// The table card's optional header.
  ///
  /// This is typically a [Text] widget, but can also be a [Row] of
  /// [TextButton]s. To show icon buttons at the top end side of the table with
  /// a header, set the [actions] property.
  ///
  /// If items in the table are selectable, then, when the selection is not
  /// empty, the header is replaced by a count of the selected items. The
  /// [actions] are still visible when items are selected.
  final Widget? header;

  /// Icon buttons to show at the top end side of the table. The [header] must
  /// not be null to show the actions.
  ///
  /// Typically, the exact actions included in this list will vary based on
  /// whether any rows are selected or not.
  ///
  /// These should be size 24.0 with default padding (8.0).
  final List<Widget>? actions;

  /// Invoked when the user switches to another page.
  ///
  /// The value is the index of the first row on the currently displayed page.
  final void Function(int page)? onPageChanged;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// This value is optional and defaults to kMinInteractiveDimension if not
  /// specified.
  final double dataRowHeight;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double horizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Flag to display the pagination buttons to go to the first and last pages.

  final bool showFirstLastButtons;

  /// The number of rows to show on each page.
  ///
  /// Defaults to 10
  final int rowsPerPage;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Defines the color of the arrow heads in the footer.
  final Color? arrowHeadColor;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.

  final double? checkboxHorizontalMargin;

  @override
  // ignore: library_private_types_in_public_api
  _FirestoreTableState createState() => _FirestoreTableState();
}

class _FirestoreTableState extends State<FirebaseDatabaseDataTable> {
  late final source = _Source(
    getHeaders: () => widget.columnLabels,
    getOnError: () => widget.onError,
    selectionEnabled: selectionEnabled,
    rowsPerPage: widget.rowsPerPage,
    onEditItem: onEditItem,
  );

  bool get selectionEnabled => widget.canDeleteItems;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      query: widget.query,
      builder: (context, snapshot, child) {
        source.setFromSnapshot(snapshot);

        return AnimatedBuilder(
          animation: source,
          builder: (context, child) {
            final actions = [
              ...?widget.actions,
              if (widget.canDeleteItems && source._selectedRowIds.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: source.onDeleteSelectedItems,
                ),
            ];
            return PaginatedDataTable(
              source: source,
              onSelectAll: selectionEnabled ? source.onSelectAll : null,
              onPageChanged: widget.onPageChanged,
              showCheckboxColumn: widget.showCheckboxColumn,
              arrowHeadColor: widget.arrowHeadColor,
              checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
              columnSpacing: widget.columnSpacing,
              dataRowHeight: widget.dataRowHeight,
              dragStartBehavior: widget.dragStartBehavior,
              headingRowHeight: widget.headingRowHeight,
              horizontalMargin: widget.horizontalMargin,
              rowsPerPage: widget.rowsPerPage,
              showFirstLastButtons: widget.showFirstLastButtons,
              sortAscending: widget.sortAscending,
              sortColumnIndex: widget.sortColumnIndex,
              header:
                  actions.isEmpty ? null : (widget.header ?? const SizedBox()),
              actions: actions.isEmpty ? null : actions,
              columns: [
                for (final head in widget.columnLabels.values)
                  DataColumn(
                    label: head,
                  )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> onEditItem(
    DataSnapshot snapshot,
    Object? value,
    String propertyName,
  ) async {
    final result = await showDialog<_Edit?>(
      context: context,
      builder: (context) {
        var formState = _initialFormStateOfValue(value);

        return StatefulBuilder(
          builder: (context, setState) {
            void onTypeChanged(_PropertyType? newType) {
              setState(
                () {
                  // Delaying dispose as otherwise the next build
                  // will throw because it'll call "removeListener"
                  Future.delayed(
                    const Duration(milliseconds: 10),
                    formState.dispose,
                  );
                  formState = _initialFormStateForType(newType);
                },
              );
            }

            void onFormChange(_FormState newFormState) {
              setState(() => formState = newFormState);
            }

            return Dialog(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    // Make sure that the modal is as small as possible, yet
                    // allow the button bar to fill the width
                    child: IntrinsicWidth(
                      child: Column(
                        // Ensures that switching between type correctly
                        // applies "autoFocus" to the new inputs
                        key: ObjectKey(formState.type),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PropertyTypeDropdown(
                            formState: formState,
                            onTypeChanged: onTypeChanged,
                          ),
                          const SizedBox(height: 8),
                          _PropertyTypeForm(
                            formState: formState,
                            onFormStateChange: onFormChange,
                          ),
                          const SizedBox(height: 10),
                          _EditModalButtonBar(
                            formState: formState,
                            ref: snapshot.ref,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    await snapshot.ref.update({propertyName: result.newValue});
  }
}

/// Takes care of the type-specific form
class _PropertyTypeForm extends StatelessWidget {
  const _PropertyTypeForm({
    Key? key,
    required this.formState,
    required this.onFormStateChange,
  }) : super(key: key);

  final _FormState formState;
  final ValueChanged<_FormState> onFormStateChange;

  @override
  Widget build(BuildContext context) {
    final localizations = FirebaseUILocalizations.labelsOf(context);
    final formState = this.formState;

    if (formState is _NumberFormState) {
      return SizedBox(
        width: 200,
        child: TextField(
          autofocus: true,
          controller: formState.controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(
              RegExp('[0-9]+?.?[0-9]*'),
            ),
          ],
          decoration: InputDecoration(labelText: localizations.valueLabel),
        ),
      );
    } else if (formState is _StringFormState) {
      return SizedBox(
        width: 200,
        child: TextField(
          autofocus: true,
          controller: formState.controller,
          decoration: InputDecoration(labelText: localizations.valueLabel),
        ),
      );
    } else if (formState is _BooleanFormState) {
      return Checkbox(
        onChanged: (_) =>
            onFormStateChange(_BooleanFormState(!formState.value)),
        value: formState.value,
      );
    }

    return const SizedBox();
  }
}

class _EditModalButtonBar extends StatelessWidget {
  const _EditModalButtonBar({
    Key? key,
    required this.formState,
    required this.ref,
  }) : super(key: key);

  final _FormState formState;
  final DatabaseReference ref;

  @override
  Widget build(BuildContext context) {
    final localizations = FirebaseUILocalizations.labelsOf(context);

    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      alignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancelLabel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, formState.submit(ref));
          },
          child: Text(localizations.updateLabel),
        ),
      ],
    );
  }
}

class _PropertyTypeDropdown extends StatelessWidget {
  const _PropertyTypeDropdown({
    Key? key,
    required this.formState,
    required this.onTypeChanged,
  }) : super(key: key);

  final _FormState? formState;

  final ValueChanged<_PropertyType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = FirebaseUILocalizations.labelsOf(context);

    return DropdownButtonFormField<_PropertyType?>(
      value: formState?.type,
      decoration: InputDecoration(labelText: localizations.typeLabel),
      items: [
        DropdownMenuItem(
          value: _PropertyType.string,
          child: Text(localizations.stringLabel),
        ),
        DropdownMenuItem(
          value: _PropertyType.number,
          child: Text(localizations.numberLabel),
        ),
        DropdownMenuItem(
          value: _PropertyType.boolean,
          child: Text(localizations.booleanLabel),
        ),
        DropdownMenuItem(child: Text(localizations.nullLabel)),
      ],
      onChanged: onTypeChanged,
    );
  }
}

_FormState _initialFormStateOfValue(Object? value) {
  if (value == null) {
    return const _NullFormState();
  } else if (value is num) {
    return _NumberFormState(value.toString());
  } else if (value is bool) {
    return _BooleanFormState(value);
  } else if (value is String) {
    return _StringFormState(value);
  } else {
    throw UnsupportedError('Unknown type ${value.runtimeType}');
  }
}

_FormState _initialFormStateForType(_PropertyType? type) {
  switch (type) {
    case null:
      return const _NullFormState();
    case _PropertyType.boolean:
      return const _BooleanFormState(true);
    case _PropertyType.number:
      return _NumberFormState('');
    case _PropertyType.string:
      return _StringFormState('');
  }
}

enum _PropertyType {
  number,
  boolean,
  string,
}

abstract class _FormState {
  const _FormState();
  _PropertyType? get type;

  _Edit submit(DatabaseReference ref) => throw UnimplementedError();

  void dispose() {}
}

class _NumberFormState extends _FormState {
  _NumberFormState(String text)
      : controller = TextEditingController(text: text);

  final TextEditingController controller;

  @override
  _PropertyType get type => _PropertyType.number;

  @override
  _Edit submit(DatabaseReference ref) => _Edit(num.parse(controller.text));

  @override
  void dispose() => controller.dispose();
}

class _StringFormState extends _FormState {
  _StringFormState(String text)
      : controller = TextEditingController(text: text);

  final TextEditingController controller;

  @override
  _PropertyType get type => _PropertyType.string;

  @override
  _Edit submit(DatabaseReference ref) => _Edit(controller.text);

  @override
  void dispose() => controller.dispose();
}

class _BooleanFormState extends _FormState {
  const _BooleanFormState(this.value);

  final bool value;

  @override
  _PropertyType get type => _PropertyType.boolean;

  @override
  _Edit submit(DatabaseReference ref) => _Edit(value);
}

class _NullFormState extends _FormState {
  const _NullFormState();

  @override
  _PropertyType? get type => null;

  @override
  _Edit submit(DatabaseReference ref) => _Edit(null);
}

/// A data holder class to differentiate setting a property to null from
/// not modifying the property at all.
class _Edit {
  _Edit(this.newValue);
  final Object? newValue;
}

class _Source extends DataTableSource {
  _Source({
    required this.getHeaders,
    required this.getOnError,
    required bool selectionEnabled,
    required int rowsPerPage,
    required this.onEditItem,
  })  : _selectionEnabled = selectionEnabled,
        _rowsPerpage = rowsPerPage;

  final void Function(
    DataSnapshot snapshot,
    Object? value,
    String propertyName,
  ) onEditItem;

  int _rowsPerpage;
  int get rowsPerPage => _rowsPerpage;
  set rowsPerPage(int value) {
    if (value != _rowsPerpage) {
      _rowsPerpage = value;
      notifyListeners();
    }
  }

  bool _selectionEnabled;
  bool get selectionEnabled => _selectionEnabled;
  set selectionEnabled(bool value) {
    if (value != _selectionEnabled) {
      _selectionEnabled = value;
      notifyListeners();
    }
  }

  final Map<String, Widget> Function() getHeaders;
  final void Function(Object error, StackTrace stackTrace)? Function()
      getOnError;

  final _selectedRowIds = <String>{};

  @override
  int get selectedRowCount => _selectedRowIds.length;

  @override
  bool get isRowCountApproximate =>
      _previousSnapshot!.isFetching || _previousSnapshot!.hasMore;

  @override
  int get rowCount {
    // Emitting an extra item during load or before reaching the end
    // allows the DataTable to show a spinner during load & let the user
    // navigate to next page
    if (_previousSnapshot!.isFetching || _previousSnapshot!.hasMore) {
      return _previousSnapshot!.docs.length + rowsPerPage;
    }

    return _previousSnapshot!.docs.length;
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _previousSnapshot!.docs.length) {
      _previousSnapshot!.fetchMore();
    }
    if (index >= _previousSnapshot!.docs.length) return null;

    final doc = _previousSnapshot!.docs[index];

    return DataRow(
      selected: _selectedRowIds.contains(doc.key),
      onSelectChanged: selectionEnabled
          ? (selected) {
              if (selected == null) return;

              if ((selected && _selectedRowIds.add(doc.key!)) ||
                  (!selected && _selectedRowIds.remove(doc.key))) {
                notifyListeners();
              }
            }
          : null,
      cells: [
        for (final head in getHeaders().keys)
          DataCell(
            _ValueView(
              doc.children.firstWhereOrNull((e) => e.key == head)?.value,
            ),
            onTap: () {
              onEditItem(
                doc,
                doc.children.firstWhereOrNull((e) => e.key == head)?.value,
                head,
              );
            },
          ),
      ],
    );
  }

  FirebaseQueryBuilderSnapshot? _previousSnapshot;

  void setFromSnapshot(FirebaseQueryBuilderSnapshot snapshot) {
    if (snapshot == _previousSnapshot) return;

    // Try to preserve the selection status when the snapshot got updated,
    // such as when more content got loaded.
    final wereAllItemsSelected =
        _previousSnapshot?.docs.length == _selectedRowIds.length &&
            _previousSnapshot!.docs.isNotEmpty;

    _previousSnapshot = snapshot;
    if (wereAllItemsSelected) onSelectAll(true);
    notifyListeners();
  }

  void onSelectAll(bool? selected) {
    if (selected == null) return;

    if (selected) {
      _selectedRowIds.addAll(_previousSnapshot!.docs.map((e) => e.key!));
    } else {
      _selectedRowIds.clear();
    }
    notifyListeners();
  }

  void onDeleteSelectedItems() {
    for (final doc in _previousSnapshot!.docs) {
      if (_selectedRowIds.contains(doc.key)) {
        doc.ref.remove().then<void>(
              (value) => _selectedRowIds.remove(doc.key),
              onError: getOnError(),
            );
      }
    }
  }
}

class _ValueView extends StatelessWidget {
  const _ValueView(this.value, {Key? key}) : super(key: key);

  final Object? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) {
      return Text('null', style: Theme.of(context).textTheme.bodySmall);
    } else {
      return Text(value.toString());
    }
  }
}
