import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestBugWidget extends StatefulWidget {
  const TestBugWidget({Key? key}) : super(key: key);

  @override
  State<TestBugWidget> createState() => _TestBugWidgetState();
}

class _TestBugWidgetState extends State<TestBugWidget> {
  StreamSubscription? _subscription;

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
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('test_10153')
        .doc('test')
        .snapshots()
        .listen((event) {
      print(event.data());
      print('new test has arrived');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> transactThenGet() async {
    final docRef =
        FirebaseFirestore.instance.collection('test_10153').doc('test');
    var newPopulation;
    final a =
        await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final prevPopulation = snapshot.get('population');
      newPopulation = prevPopulation + 1;
      print('Updating to: $newPopulation');
      transaction.update(docRef, {'population': newPopulation});
      return newPopulation;
    });
    print('Returned: $a');
    Map<String, dynamic> updated =
        (await docRef.get(const GetOptions(source: Source.server))).data()!;
    print('Expecting : ${newPopulation.toString()}');
    print('Got : ${updated['population'].toString()}');
  }

  Future<void> updateThenGet() async {
    final docRef =
        FirebaseFirestore.instance.collection('test_10153').doc('test');
    final snapshot = await docRef.get();
    final prevPopulation = snapshot.get('population');
    final newPopulation = prevPopulation + 1;
    await docRef.update({'population': newPopulation});
    Map<String, dynamic> updated =
        (await docRef.get(const GetOptions(source: Source.server))).data()!;
    print('Expecting : ${newPopulation.toString()}');
    print('Got : ${updated['population'].toString()}');
  }
}
