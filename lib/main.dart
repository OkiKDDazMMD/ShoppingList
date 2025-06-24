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
  // Firestoreの特定のドキュメントへの参照を定義します。
  // これにより、何度もパスを指定する必要がなくなります。
  final DocumentReference _counterDocRef = 
      FirebaseFirestore.instance.collection('CollectionTest').doc('DocumentTest');

  // initState() と load() は不要になります。
  // StreamBuilderがリアルタイムでデータを監視し、UIを更新します。
  @override
  void initState() {
    super.initState();
    // ここで何か初期設定が必要な場合は記述しますが、
    // カウンターの読み込みはStreamBuilderに任せます。
  }

  // _incrementCounterメソッドを改善します。
  void _incrementCounter() async {
    try {
      // FieldValue.increment(1) を使用して、Firestore側で 'count' フィールドの値を1増加させます。
      // SetOptions(merge: true) を指定することで、
      // ドキュメントが存在しない場合は作成し、既存の他のフィールドを上書きせずに 'count' フィールドだけを更新します。
      await _counterDocRef.set(
        {'count': FieldValue.increment(1)},
        SetOptions(merge: true), 
      );
      // UIはStreamBuilderによって自動的に更新されるため、
      // ここで setState やローカルのカウンターを更新する必要はありません。
      debugPrint('Firestoreのカウントをインクリメントしました！');
    } catch (e) {
      debugPrint('カウントの更新に失敗しました: $e');
      // エラーハンドリングをここに追加できます。
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // StreamBuilderを使ってFirestoreのドキュメントの変更をリアルタイムで監視します。
        child: StreamBuilder<DocumentSnapshot>(
          // 監視するストリームを指定します。ここでは特定のドキュメントのスナップショットです。
          stream: _counterDocRef.snapshots(),
          // ビルダー関数はストリームから新しいデータが来るたびに呼び出されます。
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            // エラーが発生した場合の表示
            if (snapshot.hasError) {
              return Text('データの読み込み中にエラーが発生しました: ${snapshot.error}');
            }

            // データがまだロード中の場合の表示
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("ロード中...");
            }

            // データが利用可能な場合
            // ドキュメントが存在するかどうかを確認します。
            int currentCount = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              // ドキュメントのデータをMapとして取得します。
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              // 'count' フィールドが存在し、数値であることを確認して値を取得します。
              if (data != null && data.containsKey('count')) {
                // Firestoreの数値は 'num' 型で返されることがあるため、.toInt() で int に変換します。
                currentCount = (data['count'] as num).toInt();
              }
            }
            // ドキュメントが存在しない（まだ誰もカウントしていない）場合、currentCount はデフォルトの 0 のままです。

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'ボタンを押した回数:',
                ),
                Text(
                  '$currentCount',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            );
          },
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

