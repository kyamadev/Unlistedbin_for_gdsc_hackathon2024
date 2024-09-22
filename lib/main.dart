import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/RepositoryLoader.dart';
import 'package:for_gdsc_2024/view/startup/login.dart';
import 'package:provider/provider.dart';
import 'package:for_gdsc_2024/view/repository.dart';
import 'package:for_gdsc_2024/view/startup/start.dart';
import 'package:for_gdsc_2024/view/components/changeNotifire.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env");

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // マルチプロバイダーを使用して複数のプロバイダーを提供可能
      providers: [
        ChangeNotifierProvider<AppUserProvider>(
          create: (_) => AppUserProvider(), // AppUserProviderのインスタンスを作成
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, //デバッグバナー
        title: 'Unlistedbin',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0E607E), // AppBarの背景色
            foregroundColor: Colors.white, // AppBarの文字色
          ),
          scaffoldBackgroundColor: const Color(0xFF00413E), // 背景色
          useMaterial3: true,
        ),

        onGenerateRoute: (settings) {
          String routeName = settings.name ?? '/';
          if (kIsWeb && routeName == '/') {
            routeName =
                Uri.base.path + (Uri.base.hasQuery ? '?${Uri.base.query}' : '');
          }
          final Uri uri = Uri.parse(routeName);
          print('Navigated to: $routeName');

          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'repo') {
            String repoId = uri.pathSegments[1];

            return MaterialPageRoute(
              builder: (context) => Repositoryloader(repoId: repoId),
            );
          }

          final User? user = FirebaseAuth.instance.currentUser;

          //userがnullのときはStart()を表示
          if (user == null) {
            return MaterialPageRoute(
              builder: (context) => Start(),
            );
          }

          return MaterialPageRoute(
            builder: (context) => Start(),
          );
        },
      ),
    );
  }
}
