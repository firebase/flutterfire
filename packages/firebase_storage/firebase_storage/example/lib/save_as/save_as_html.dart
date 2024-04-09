// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Initializes a DOM container where we can host elements.
web.Element _ensureInitialized(String id) {
  var target = web.document.querySelector('#$id');
  if (target == null) {
    final web.Element targetElement =
        web.document.createElement('flt-x-file') as web.HTMLElement;
    targetElement.id = id;

    web.document.querySelector('body')?.children.add(targetElement);
    target = targetElement;
  }
  return target;
}

web.HTMLAnchorElement _createAnchorElement(String href, String suggestedName) {
  final element = web.HTMLAnchorElement();
  element.href = href;
  element.download = suggestedName;
  return element;
}

/// Add an element to a container and click it
void _addElementToContainerAndClick(
  web.Element container,
  web.Element element,
) {
  // Add the element and click it
  // All previous elements will be removed before adding the new one
  container.children.add(element);
  final event = web.MouseEvent('click');
  element.dispatchEvent(event);
}

/// Present a dialog so the user can save as... a bunch of bytes.
Future<void> saveAsBytes(Uint8List bytes, String suggestedName) async {
  // Convert bytes to an ObjectUrl through Blob
  final blob = web.Blob([bytes.toJS].toJS);
  final path = web.URL.createObjectURL(blob);

  // Create a DOM container where we can host the anchor.
  final target = _ensureInitialized('__x_file_dom_element');

  // Create an <a> tag with the appropriate download attributes and click it
  // May be overridden with XFileTestOverrides
  final web.HTMLAnchorElement element =
      _createAnchorElement(path, suggestedName);

  // Clear the children in our container so we can add an element to click
  do {
    target.children.item(0)?.remove();
  } while (target.children.length > 0);

  _addElementToContainerAndClick(target, element);
}
