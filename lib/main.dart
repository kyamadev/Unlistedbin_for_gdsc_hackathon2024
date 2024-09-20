import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:for_gdsc_2024/view/components/changeNotifire.dart';
import 'package:for_gdsc_2024/view/startup/login.dart';
import 'package:for_gdsc_2024/view/startup/start.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  //Firebaseのパッケージを使用
  WidgetsFlutterBinding.ensureInitialized();
  //firebaseの情報が書いてある環境変数を読み込む
  await dotenv.load(fileName: ".env");
  //firebase初期化
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      //ユーザ名の変更を感知
      create: (context) => AppUserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          //基本となるAppbarの背景色の設定
          backgroundColor: Color(0xFF0E607E),
          foregroundColor: Colors.white,
        ),
        //Scaffoldの背景色の設定
        scaffoldBackgroundColor: const Color(0xFF00413E),
        useMaterial3: true,
      ),
      //最初に起動する画面
      home: Start(),
    );
  }
}
