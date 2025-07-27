import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート！

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
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth Demo',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MyHomePage(title: 'Flutter Firebase Auth Demo');
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> signIn() async {
    setState(() => error = '');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'ログインに失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ログイン', style: TextStyle(fontSize: 24)),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: signIn,
                child: const Text('ログイン'),
              ),
            ],
          ),
        ),
      ),
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

  String statusMessage = 'ボタンを押してFirestoreを更新してください';

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
      setState(() {
        statusMessage = '✅ Firestoreが更新されました';
      });
    } catch (e, stackTrace) {
      setState(() {
        statusMessage = '❌ Firestore更新エラー: $e StackTrace: $stackTrace';
      });
    }
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
            const SizedBox(height: 20),
            // StreamBuilderを使ってFirestoreのドキュメントの変更をリアルタイムで監視します。
            StreamBuilder<DocumentSnapshot>(
              // 監視するストリームを指定します。ここでは特定のドキュメントのスナップショットです。
              stream: _counterDocRef.snapshots(),
              // ビルダー関数はストリームから新しいデータが来るたびに呼び出されます。
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                int currentCount = 0;
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
                if (snapshot.hasData && snapshot.data!.exists && currentCount < 1001) {
                  // ドキュメントのデータをMapとして取得します。
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  // 'count' フィールドが存在し、数値であることを確認して値を取得します。
                  if (data != null && data.containsKey('count')) {
                    // Firestoreの数値は 'num' 型で返されることがあるため、.toInt() で int に変換します。
                    currentCount = (data['count'] as num).toInt();
                  }
                }
                return Column(
                  children: [
                  const Text('ボタンを押した回数:'),
                  SelectableText('$currentCount',
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: _incrementCounter,
                    tooltip: 'Increment',
                    child: const Text('+ ボタン +'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
  }
}