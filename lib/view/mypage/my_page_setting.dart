import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/mypage/mypage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/size_config.dart';
import '../components/mypage_appbar.dart';

class MyPageSetting extends StatefulWidget {
  final String repoId;
  const MyPageSetting({Key? key, required this.repoId}) : super(key: key);

  @override
  State<MyPageSetting> createState() => _MyPageSettingState();
}

class _MyPageSettingState extends State<MyPageSetting> {
  int _privacyVal = 0; //初めはUnlisted
  final userAuth = FirebaseAuth.instance;
  String url_key = "";
  String reponame = "";
  bool isDisposed = false; // disposeされたかを追跡

  @override
  void initState() {
    super.initState();
    _fetchRepository();
  }

  @override
  void dispose() {
    isDisposed = true; // disposeの状態を追跡
    super.dispose();
  }

  Future<void> _fetchRepository() async {
    if (userAuth.currentUser != null) {
      //ユーザがしっかりログインしている場合
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.currentUser!.uid)
            .collection('repositories')
            .doc(widget.repoId)
            .get();

        //レポジトリの名前とurl_keyを設定
        if (!isDisposed && mounted) {
          // mountedがtrueのときのみsetState()を呼び出す
          setState(() {
            reponame = snapshot.get('name') as String;
            url_key = snapshot.get('url_key') as String;
            _privacyVal =snapshot.get('mode');
          });
        }
      } catch (e) {
        print("Error fetching repository: $e");
      }
    } else {
      print("userがログインしていません");
    }
  }

  //指定されたrepository の削除
  Future<void> _deleteRepository() async {
    //アカウントからぬける
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("本当にしてもよろしいですか？"),
        actions: [
          TextButton(
            child: Text("キャンセル"),
            onPressed: () {
              Navigator.of(context).pop(false); // キャンセルを返す
            },
          ),
          TextButton(
            child: Text("はい"),
            onPressed: () {
              Navigator.of(context).pop(true); // 削除を返す
            },
          ),
        ],
      ),
    );
    if (confirm == true) {
      // ログインしているか確認
      if (userAuth.currentUser != null) {
        try {
          Fluttertoast.showToast(msg: '削除しています...');
          //　フォルダ内のすべてのファイルを削除
          await _deleteFolder(
              'repositories/${userAuth.currentUser!.uid}/${widget.repoId}/');

          // ドキュメントを削除
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userAuth.currentUser!.uid)
              .collection('repositories')
              .doc(widget.repoId)
              .delete();
          print('リポジトリとそのフォルダが削除されました: ${widget.repoId}');
          Fluttertoast.showToast(msg: '削除されました');
          // 削除が完了したらナビゲーション
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Mypage()),
            (_) => false,
          );
        } catch (e) {
          print("リポジトリ削除中にエラーが発生しました: $e");
          Fluttertoast.showToast(msg: "リポジトリ削除中にエラーが発生しました: $e");
          // エラーハンドリング（例: エラーメッセージを表示する）);
        }
      } else {
        // ユーザーがログインしていない場合の処理
        print("ユーザーがログインしていません");
        Fluttertoast.showToast(msg: "ユーザーがログインしていません");
      }
    }
  }

  //_deleteRepository()で呼ばれているメソッド
  Future<void> _deleteFolder(String folderPath) async {
    //フォルダ内の全てのファイルを取得
    final ListResult result =
        await FirebaseStorage.instance.ref(folderPath).listAll();
    // フォルダ内のファイルを1つずつ削除
    for (Reference fileRef in result.items) {
      await fileRef.delete();
      print('Deleted file: ${fileRef.fullPath}');
    }

    // サブフォルダがある場合は再帰的に削除
    for (Reference prefix in result.prefixes) {
      await _deleteFolder(prefix.fullPath);
    }
  }

  Future<void> _setMode(int mode) async {
    if (userAuth.currentUser != null) {
      //ユーザがしっかりログインしている場合
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.currentUser!.uid)
            .collection('repositories')
            .doc(widget.repoId)
            .update({'mode': mode});
        print("modeを登録した$mode");
        if (mode == 0) {
          Fluttertoast.showToast(msg: "誰でも見れるようになりました");
        } else {
          Fluttertoast.showToast(msg: "閲覧制限が掛かりました");
        }
      } catch (e) {
        print("Error fetching repository: $e");
      }
    } else {
      print("userがログインしていません");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              //幅-> 画面幅の60%
              width: SizeConfig.blockSizeHorizontal! * 60,
              color: Color(0xFF006788),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Repository name',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      //レポジトリ名を表示
                      Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          padding: EdgeInsets.all(8),
                          color: Colors.white,
                          child: Text(
                            reponame,
                            maxLines: null, // 行数を制限しない
                            softWrap: true, // 折り返しを許可
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          )),

                      SizedBox(height: 30),
                      //URL を表示
                      Text(
                        'Share Url',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          padding: EdgeInsets.all(8),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  url_key,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_paste,
                                    color: Colors.black54),
                                onPressed: () {
                                  // クリップボードボタンが押されたときの処理
                                  Clipboard.setData(
                                      ClipboardData(text: '$url_key'));
                                  Fluttertoast.showToast(
                                      msg: 'Copied!',
                                      textColor: Colors.white,
                                      timeInSecForIosWeb: 2);
                                },
                              ),
                            ],
                          )),

                      SizedBox(height: 30),
                      //レポジトリ削除 ボタン
                      OutlinedButton(
                        child: const Text('Delete repository'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xff870202),
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () async {
                          _deleteRepository();
                        },
                      ),
                      SizedBox(height: 50),

                      //対象のURLのモードを選択
                      Text(
                        "Mode",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      // Radioボタン private
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _privacyVal,
                            onChanged: (value) {
                              setState(() {
                                _privacyVal = value!;
                                print("_privacyVal:$_privacyVal");
                                _setMode(_privacyVal);
                              });
                            },
                          ),
                          SizedBox(width: 10.0),
                          const Flexible(
                            child: FittedBox(
                              child: Text(
                                'Unlisted (anyone with the link can view)',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      //radioボタン unlisted
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: 1,
                            groupValue: _privacyVal,
                            onChanged: (value) async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("モード変更"),
                                  content: Text("限定公開になります"),
                                  actions: [
                                    TextButton(
                                      child: Text("キャンセル"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(false); // キャンセルを返す
                                      },
                                    ),
                                    TextButton(
                                      child: Text("はい"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // モード変更を許可
                                      },
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                setState(() {
                                  _privacyVal = value!;
                                  _setMode(_privacyVal);
                                  print("変更done: $_privacyVal");
                                });
                              }
                            },
                          ),
                          SizedBox(width: 10.0),
                          const Flexible(
                            child: FittedBox(
                              child: Text(
                                'Private (Share URL or disabled)',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
