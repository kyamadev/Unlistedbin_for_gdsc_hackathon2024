import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/checkUser.dart';

import '../repository.dart';
import 'login.dart';

class Repositoryloader extends StatefulWidget {
  final String repoId;
  const Repositoryloader({
    super.key,
    required this.repoId});

  @override
  State<Repositoryloader> createState() => _RepositoryloaderState();
}

class _RepositoryloaderState extends State<Repositoryloader> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadRepository();
  }

  //repoIdからuserIdをとってくる
  Future<void> getUserIdFromRepoId(String repositoryId) async {
    try {
      // Firestoreの全ユーザーを取得
      final userDocs = await FirebaseFirestore.instance.collection('users').get();

      for (var doc in userDocs.docs) {

        // 各ユーザーのrepositoriesサブコレクションを確認
        var repositories = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('repositories')
            .doc(repositoryId)
            .get();

        if (repositories.exists) {
          setState(() {
            userId = doc.id;
          });
          return;  // userIdが見つかったので終了
        }
      }

      print('リポジトリが見つかりません: $repositoryId');
    } catch (e) {
      print('ユーザーID取得エラー: $e');
    }
  }


  Future<void> _loadRepository() async{
    try{
      await getUserIdFromRepoId(widget.repoId);

      // Firestoreからリポジトリのドキュメントを取得
      DocumentSnapshot repoSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .doc(widget.repoId)
          .get();

      if(repoSnapshot.exists){
        int mode =repoSnapshot.get('mode');

        if(mode==0){
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => RepositoryScreen(repoId: widget.repoId, path: '')), (_) => false);
        }
        if(mode==1){
          final User? user = FirebaseAuth.instance.currentUser;
          //Userがnullのとき
          if(user==null){
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute( builder: (context) => Checkuser(userId: userId,repoId: widget.repoId)), (_) => false);
          }
          // 作成者とログインしているユーザーが一致する場合
          else if (user.uid == userId) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => RepositoryScreen(repoId: widget.repoId, path: '')), (_) => false);
          }else{
            Fluttertoast.showToast(msg: "権限がないため見れません");
          }
        }
      }else{
        Fluttertoast.showToast(msg: "リポジトリが見つかりません");
      }
    }catch(e){
      Fluttertoast.showToast(msg: "Firestoreからリポジトリのドキュメントを取得したかった error:$e");
      print("error:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loading...'),
      ),body: Center(
      child: CircularProgressIndicator(),
    ),
    );
  }
}
