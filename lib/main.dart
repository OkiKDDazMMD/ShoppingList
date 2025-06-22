import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBIjgEC3Cu8c5X9UxhgmZzxeFnn8NceigI",
      authDomain: "friendlyeats-6010d.firebaseapp.com",
      projectId: "friendlyeats-6010d",
      storageBucket: "friendlyeats-6010d.firebasestorage.app",
      messagingSenderId: "1064013134599",
      appId: "1:1064013134599:web:9a14d3c4962f4be44863a2",
      measurementId: "G-36QDXF9CEL"
    ),
 );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo 1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    await FirebaseFirestore.instance
        .collection('CollectionTest')
        .doc('DocumentTest')
        .get()
        .then((DocumentSnapshot snapshot) {
      var count = snapshot.get('count');
      debugPrint(count.toString());
      setState(() {
        _counter = count as int;
      });
    });
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    await FirebaseFirestore.instance.collection('CollectionTest').doc('DocumentTest').set({'count': _counter});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

