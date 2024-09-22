import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore用のimport
import 'dart:convert'; // For utf8 decoding

class FileScreen extends StatefulWidget {
  final String repoId;
  final String path;

  const FileScreen({Key? key, required this.repoId, required this.path})
      : super(key: key);

  @override
  _FileScreenState createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  String? fileContent;
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadFile();
  }

  Future<void> _getUserIdAndLoadFile() async {
    await getUserIdFromRepoId(widget.repoId);
    if (userId != null) {
      _loadFile();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFile() async {
    try {
      // Firebase Storageのファイルを参照
      final ref = FirebaseStorage.instance
          .ref('repositories')
          .child(userId!)
          .child(widget.repoId)
          .child(widget.path);

      // ダウンロードURLを取得
      final url = await ref.getDownloadURL();

      // HttpRequestを使用してデータを取得
      final request = html.HttpRequest();
      request
        ..open('GET', url)
        ..onLoadEnd.listen((event) {
          if (request.status == 200) {
            setState(() {
              fileContent = request.responseText ?? '';
              isLoading = false;
            });
          } else {
            print('ステータスコード: ${request.status}');
            print('レスポンステキスト: ${request.responseText}');
            throw Exception('ファイルの読み込みに失敗しました');
          }
        })
        ..onError.listen((event) {
          print('エラーが発生しました: ${event.type}');
          throw Exception('ネットワークエラーが発生しました');
        })
        ..send();
    } catch (e) {
      print('ファイルの読み込みに失敗しました: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUserIdFromRepoId(String repositoryId) async {
    try {
      // Firestoreの全ユーザーを取得
      final userDocs =
          await FirebaseFirestore.instance.collection('users').get();

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
            userId = doc.id; // userIdをセット
          });
          return; // userIdが見つかったので終了
        }
      }

      print('リポジトリが見つかりません: $repositoryId');
    } catch (e) {
      print('ユーザーID取得エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Viewer'),
      ),
      // bodyの背景色はデフォルト（緑色）
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : fileContent == null
              ? Center(
                  child: Text(
                    'ファイルが見つかりません',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.0), // 上部に20のスペースを追加
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width *
                              0.1, // 左右に10%のパディング
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.path.split('/').last, // ファイル名を表示
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.0), // ファイル名と内容の間にスペースを追加
                            Container(
                              color: Colors.black, // コード部分の背景を黒に設定
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    NeverScrollableScrollPhysics(), // 内部のスクロールを無効化
                                itemCount: fileContent!.split('\n').length,
                                itemBuilder: (context, index) {
                                  final lineNumber = index + 1;
                                  final lineContent =
                                      fileContent!.split('\n')[index];
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 行番号
                                      Container(
                                        width: 40,
                                        child: Text(
                                          '$lineNumber',
                                          style: TextStyle(
                                              color: Colors.grey[500]),
                                        ),
                                      ),
                                      // コード行の内容
                                      Expanded(
                                        child: Text(
                                          lineContent,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                                'monospace', // 等幅フォントを使用
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
