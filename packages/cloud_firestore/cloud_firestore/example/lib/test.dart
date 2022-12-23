import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestBugWidget extends StatefulWidget {
  const TestBugWidget({Key? key}) : super(key: key);

  @override
  State<TestBugWidget> createState() => _TestBugWidgetState();
}

class _TestBugWidgetState extends State<TestBugWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bug repro')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Listen to the stream'),
            onTap: streamListen,
          ),
          ListTile(
            title: const Text('Update then Get'),
            onTap: updateThenGet,
          ),
          ListTile(
            title: const Text('Transact then Get'),
            onTap: transactThenGet,
          )
        ],
      ),
    );
  }

  void streamListen() {
    FirebaseFirestore.instance
        .collection('test')
        .doc('test')
        .snapshots()
        .listen((event) {
      debugPrint('new test has arrived');
    });
  }

  Future<void> transactThenGet() async {
    final docRef = FirebaseFirestore.instance.collection('test').doc('test');
    var newPopulation;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final prevPopulation = snapshot.get('population');
      newPopulation = prevPopulation + 1;
      transaction.update(docRef, {'population': newPopulation});
    });
    Map<String, dynamic> updated = (await docRef.get()).data()!;
    debugPrint('Expecting : ${newPopulation.toString()}');
    debugPrint('Got : ${updated['population'].toString()}');
  }

  Future<void> updateThenGet() async {
    final docRef = FirebaseFirestore.instance.collection('test').doc('test');
    final snapshot = await docRef.get();
    final prevPopulation = snapshot.get('population');
    final newPopulation = prevPopulation + 1;
    await docRef.update({'population': newPopulation});
    Map<String, dynamic> updated = (await docRef.get()).data()!;
    debugPrint('Expecting : ${newPopulation.toString()}');
    debugPrint('Got : ${updated['population'].toString()}');
  }
}
