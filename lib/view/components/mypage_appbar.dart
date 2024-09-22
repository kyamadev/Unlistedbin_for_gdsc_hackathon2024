import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'changeNotifire.dart';

// マイページ用のカスタムAppBar
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  // `PreferredSizeWidget` を実装するために `preferredSize` をオーバーライド
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // これが必要
}

class _CustomAppBarState extends State<CustomAppBar> {
  final userAuth = FirebaseAuth.instance;
  String username = '{Username}'; // デフォルトの名前

  // ユーザー名を取得する非同期処理
  Future<void> fetchFollowername() async {
    //Userがnullじゃなかったら
    if (userAuth.currentUser != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.currentUser!.uid)
            .get();

        //ドキュメントにusernameが登録されている場合
        if (snapshot.exists && snapshot.get('username') != "") {
          setState(() {
            username = snapshot.get('username'); // ユーザー名を更新
          });
        }
        //ドキュメントにusernameが登録されていない場合=> デフォルト値かえす
        else {
          setState(() {
            // デフォルト値
            username = '{Username}';
          });
        }
      } catch (e) {
        setState(() {
          // エラーメッセージを表示
          username = "error name";
        });
      }
    } else {
      setState(() {
        // エラーメッセージを表示
        username = "No login";
      });
    }
  }

  @override
  // ウィジェットがビルドされたときに呼び出す
  void initState() {
    super.initState();
    fetchFollowername();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Unlistedbin'),
      actions: [
        Container(
          height: 60,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 10), // 余白を指定
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Consumer<AppUserProvider>(
            builder: (context, userModel, child) {
              //user名がfirebaseに入っていないときには{Username}を返す
              String displayName = userModel.username.isNotEmpty
                  ? userModel.username
                  : '{Username}';
              //boxの幅は名前の文字数に合うようにしている
              return FittedBox(fit: BoxFit.scaleDown,
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: Color(0xFF02607E),
                    fontSize: 30,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                )
              );
            },
          ),
        ),
      ],
    );
  }
}
