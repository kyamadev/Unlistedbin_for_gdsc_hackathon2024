import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


import '../../model/appuser.dart';
import '../startup/start.dart';
import 'changeNotifire.dart';

//ユーザ名の変更やログアウトをするためのdrawer

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final userAuth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final AppUser _account = AppUser();

  @override
  void initState() {
    super.initState();
    fetchAccountName();
  }

  //アカウント名取得
  Future<void> fetchAccountName() async{
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users').doc(userAuth.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        String username = snapshot.get('username');
        // コントローラーに値を反映
        _nameController.text = username;
        // UserModelに反映
        Provider.of<AppUserProvider>(context, listen: false).setUsername(username);
      }else {
        print('アカウントのデータがそもそもない');
      }
    }catch (e) {
      print('fetchに失敗: $e');
    }
  }
  //アカウント名をセットする
  Future<void> setAccountName(DocumentReference _mainReference) async{
    try{
      String username= _nameController.text;
      await _mainReference.set({
        'username': username,
      },SetOptions(merge: true));
      // UserModelにも反映
      Provider.of<AppUserProvider>(context, listen: false).setUsername(username);


      Fluttertoast.showToast(msg: "保存に成功しました");
    }catch(e){
      Fluttertoast.showToast(msg: "保存に失敗しました:$e");
    }

  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users')
        .doc(userAuth.currentUser!.uid);
    return Drawer(
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 80,
            child: DrawerHeader(
              child: Text('設定とアクティビティ'),
              decoration: BoxDecoration(
                color:  Color(0xFFC5D8E7),
              ),
            ),
          ),
          ListTile(
            title: Text('アカウント設定'),
            onTap: () async{
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("ユーザネーム"),
                  content:
                  TextField(
                    controller: _nameController,
                  ),
                  actions: [
                    TextButton(
                      child: Text("キャンセル"),
                      onPressed: () {
                        Navigator.of(context).pop(
                            false); // キャンセルを返す
                      },
                    ),
                    TextButton(
                      child: Text("保存"),
                      onPressed: () {
                        //アカウント名をfirebaseにセット
                        _account.username=_nameController.text;
                        setAccountName(_mainReference);
                        Navigator.of(context).pop(
                            true); // 削除を返す
                      },
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _account.username;
                Navigator.pop(context);
              }

            },
          ),
          ListTile(
            title: Text('ログアウト'),
            onTap: () async {
              //アカウントからぬける
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("ログアウト"),
                  content:
                  Text("ログアウトしてもよろしいですか？"),
                  actions: [
                    TextButton(
                      child: Text("キャンセル"),
                      onPressed: () {
                        Navigator.of(context).pop(
                            false); // キャンセルを返す
                      },
                    ),
                    TextButton(
                      child: Text("はい"),
                      onPressed: () {
                        Navigator.of(context).pop(
                            true); // 削除を返す
                      },
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                //ログアウト時に表示しているユーザ名初期化
                Provider.of<AppUserProvider>(context, listen: false).reset();
                _nameController.clear();

                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Start()),
                      (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
