import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firebase_firestore.dart';
import 'package:firebase/src/assets/assets.dart';

main() async {
  //Use for firebase package development only
  await config();

  try {
    fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket,
        projectId: projectId);

    new MessagesApp().showMessages();
  } on fb.FirebaseJsNotLoadedException catch (e) {
    print(e);
  }
}

class MessagesApp {
  final CollectionReference ref;
  final UListElement messages;
  final InputElement newMessage;
  final InputElement submit;
  final FormElement newMessageForm;

  MessagesApp()
      : ref = fb.firestore().collection("pkg_firestore"),
        messages = querySelector("#messages"),
        newMessage = querySelector("#new_message"),
        submit = querySelector('#submit'),
        newMessageForm = querySelector("#new_message_form") {
    newMessage.disabled = false;

    submit.disabled = false;

    this.newMessageForm.onSubmit.listen((e) async {
      e.preventDefault();

      if (newMessage.value.trim().isNotEmpty) {
        // store also created at for purposes of ordering
        var map = {"text": newMessage.value, "createdAt": new DateTime.now()};

        try {
          newMessage.value = "";
          await ref.add(map);
        } catch (e) {
          print("Error while writing document, $e");
        }
      }
    });
  }

  showMessages() {
    this.ref.orderBy("createdAt").onSnapshot.listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        var docSnapshot = change.doc;
        switch (change.type) {
          case "added":
            _renderItemView(docSnapshot);
            break;
          case "removed":
            _removeItemView(docSnapshot);
            break;
          case "modified":
            _modifyItemView(docSnapshot);
            break;
        }
      }
    });
  }

  _renderItemView(DocumentSnapshot docSnapshot) {
    var spanElement = new SpanElement()..text = docSnapshot.data()["text"];

    var aElementDelete = new AnchorElement(href: "#")
      ..text = "Delete"
      ..onClick.listen((e) {
        e.preventDefault();
        _deleteItem(docSnapshot);
      });

    var aElementUpdate = new AnchorElement(href: "#")
      ..text = "To Uppercase"
      ..onClick.listen((e) {
        e.preventDefault();
        _uppercaseItem(docSnapshot);
      });

    var element = new LIElement()
      ..id = "item-${docSnapshot.id}"
      ..append(spanElement)
      ..append(aElementDelete)
      ..append(aElementUpdate);
    messages.append(element);
  }

  _removeItemView(DocumentSnapshot docSnapshot) {
    var element = querySelector("#item-${docSnapshot.id}");

    if (element != null) {
      element.remove();
    }
  }

  _modifyItemView(DocumentSnapshot docSnapshot) {
    var element = querySelector("#item-${docSnapshot.id} span");

    if (element != null) {
      element.text = docSnapshot.data()["text"];
    }
  }

  _deleteItem(DocumentSnapshot docSnapshot) async {
    try {
      await this.ref.doc(docSnapshot.id).delete();
    } catch (e) {
      print("Error while deleting item, $e");
    }
  }

  _uppercaseItem(DocumentSnapshot docSnapshot) async {
    var value = docSnapshot.data();
    var valueUppercase = value["text"].toString().toUpperCase();
    value["text"] = valueUppercase;

    try {
      await this.ref.doc(docSnapshot.id).update(data: value);
    } catch (e) {
      print("Error while updating item, $e");
    }
  }
}
