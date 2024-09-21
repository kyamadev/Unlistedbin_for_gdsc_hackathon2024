import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/mypage/mypage.dart';

import '../../config/size_config.dart';
import '../components/mypage_appbar.dart';
import '../components/mypage_drawer.dart';

class MyPageSetting extends StatefulWidget {
  final String repoId;
  const MyPageSetting({
    Key? key,required this.repoId
  }): super(key: key);

  @override
  State<MyPageSetting> createState() => _MyPageSettingState();
}

class _MyPageSettingState extends State<MyPageSetting> {
  int _privacyVal=0;
  final userAuth = FirebaseAuth.instance;
  String url_key="";
  String reponame="";
  bool isDisposed = false;  // disposeされたかを追跡


  @override
  void initState(){
    super.initState();
    _fetchRepository();
  }

  @override
  void dispose() {
    isDisposed = true;  // disposeの状態を追跡
    super.dispose();
  }

  Future<void> _fetchRepository() async{
    if(userAuth.currentUser!=null){
      //ユーザがしっかりログインしている場合
      try{
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userAuth.currentUser!.uid)
            .collection('repositories')
            .doc(widget.repoId)
            .get();

        //レポジトリの名前とurl_keyを設定
        if (!isDisposed && mounted) {  // mountedがtrueのときのみsetState()を呼び出す
          setState(() {
            reponame = snapshot.get('name') as String;
            url_key = snapshot.get('url_key') as String;
          });
        }

      }catch(e){
        print("Error fetching repository: $e");
      }

    }else{
      print("userがログインしていません");
    }
  }

  Future<void> _deleteRepository() async{
    //アカウントからぬける
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content:
        Text("本当にしてもよろしいですか？"),
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
      // ログインしているか確認
      if (userAuth.currentUser != null) {
        try {
          // ドキュメントを削除
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userAuth.currentUser!.uid)
              .collection('repositories')
              .doc(widget.repoId)
              .delete();

          // 削除が完了したらナビゲーション
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Mypage()),
                (_) => false,
          );
        } catch (e) {
          print("リポジトリ削除中にエラーが発生しました: $e");
          Fluttertoast.showToast(msg:"リポジトリ削除中にエラーが発生しました: $e");
          // エラーハンドリング（例: エラーメッセージを表示する）);
        }
      } else {
        // ユーザーがログインしていない場合の処理
        print("ユーザーがログインしていません");
        Fluttertoast.showToast(msg:"ユーザーがログインしていません");

      }
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
                      //email 用のTextfield
                      Container(
                          color: Colors.white,
                          child: Text(reponame,
                            style: TextStyle(color: Colors.black, fontSize: 20),)),
                      SizedBox(height: 30),
                      //password 用のTextfield
                      Text(
                        'Share Url',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Container(
                          color: Colors.white,
                          child: Text(url_key,
                            style: TextStyle(color: Colors.black, fontSize: 20),)),
                      SizedBox(height: 30),
                      //URL再生成 ボタン
                      OutlinedButton(
                        child: const Text('Regenerate URL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:Color(0xff878702),shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(height: 30),
                      //レポジトリ削除 ボタン
                      OutlinedButton(
                        child: const Text('Delete repository'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:Color(0xff870202),shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () async{
                          _deleteRepository();
                        },
                      ),
                      SizedBox(height: 50),

                      //対象のURLのモードを選択
                      Text(
                        "Change mode",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      //radioボタン unlisted
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _privacyVal,
                            onChanged: (value){
                              setState(() {
                                _privacyVal=value!;
                              });
                            }
                            ),
                          SizedBox(width: 10.0),
                          const Flexible(child: FittedBox(child: Text('Unlisted (anyone with the link can view)',
                            style: TextStyle(color: Colors.white, fontSize: 20),))
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      //radioボタン private
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                              value: 1,
                              groupValue: _privacyVal,
                              onChanged: (value){
                                setState(() {
                                  _privacyVal=value!;
                                });
                              }
                          ),
                          SizedBox(width: 10.0),
                          Flexible(child: FittedBox(child: Text('Private (Share URL or disabled)',
                            style: TextStyle(color: Colors.white, fontSize: 20),),)),
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
