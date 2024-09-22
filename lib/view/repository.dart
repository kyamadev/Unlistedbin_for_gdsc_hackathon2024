import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:for_gdsc_2024/view/file_view.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:for_gdsc_2024/view/startup/checkUser.dart';

class RepositoryScreen extends StatefulWidget {
  final String repoId;
  final String path;

  const RepositoryScreen({super.key, required this.repoId, required this.path});

  @override
  State<RepositoryScreen> createState() => _RepositoryState();
}

class _RepositoryState extends State<RepositoryScreen> {
  List<String> content = [];
  bool isLoading = true;
  String? userId;
  String? ownerName;
  String? repoName;
  int? repoMode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }



  Future<void> _initializeData() async {
    // userIdの取得を待ってから次の処理に進む
    await getUserIdFromRepoId(widget.repoId);
    
    // userIdがnullでなければ続けてオーナー名とリポジトリ名を取得
    if (userId != null) {
      await getOwnerName(widget.repoId);
      await getRepoName(widget.repoId);
      await getRepoMode(widget.repoId);
    }
    
    // ファイルの取得処理を呼び出す
    await _fetchFiles();
    
    // データがすべて揃ったので、UIを更新
    setState(() {
      isLoading = false;
    });
  }

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
            userId = doc.id; // userIdをセット
          });
          return;  // userIdが見つかったので終了
        }
      }

      print('リポジトリが見つかりません: $repositoryId');
    } catch (e) {
      print('ユーザーID取得エラー: $e');
    }
  }

  Future<void> getOwnerName(String repositoryId) async {
    if (userId == null) return; // userIdがnullなら処理しない

    try {
      // usersコレクションからuserIdに対応するユーザーデータを取得
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .get();

      if (doc.exists) {
        setState(() {
          // 'username' フィールドを 'ownerName' に設定
          ownerName = doc.data()?['username'];
        });
      } else {
        print('ユーザーが存在しません: $userId');
      }
    } catch (e) {
      print('オーナー名取得エラー: $e');
    }
  }  

  Future<void> getRepoName(String repositoryId) async {
    if (userId == null) return; // userIdがnullなら処理しない

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .collection('repositories')
          .doc(repositoryId)
          .get();

      if (doc.exists) {
        setState(() {
          repoName = doc.data()?['name'];
        });
      } else {
        print('リポジトリが存在しません: $repositoryId');
      }
    } catch (e) {
      print('リポジトリ名取得エラー: $e');
    }
  }

  Future<void> getRepoMode(String repositoryId) async{
    if (userId == null) return; // userIdがnullなら処理しない
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .collection('repositories')
          .doc(repositoryId)
          .get();

      if (doc.exists) {
        setState(() {
          repoMode = doc.data()?['mode'];
        });
      } else {
        print('リポジトリが存在しません: $repositoryId');
      }
    } catch (e) {
      print('リポジトリモード取得エラー: $e');
    }
  }

  // Firebase Storageからファイルリストを取得するメソッド
  Future<void> _fetchFiles() async {
    if (userId == null) {
      print("userIdがnullです");
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref('repositories')
          .child(userId!) // userId!でnullでないことを保証
          .child(widget.repoId)
          .child(widget.path);

      final listResult = await storageRef.listAll(); // フォルダ内の全ファイルとフォルダを取得

      List<String> fileNames = [];
      for (var item in listResult.items) {
        fileNames.add(item.name);
      }
      for (var prefix in listResult.prefixes) {
        fileNames.add(prefix.name + '/');
      }

      setState(() {
        content = fileNames;
        isLoading = false;
      });
    } catch (e) {
      print('ファイルの取得中にエラーが発生しました: $e');
      Fluttertoast.showToast(
        msg: 'ファイルの取得中にエラーが発生しました: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        timeInSecForIosWeb: 5,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _loadMarkdownFile(String fileName) async {
    try {
      final fileRef = FirebaseStorage.instance
          .ref('repositories')
          .child(userId!)  // nullではないことを保証
          .child(widget.repoId)
          .child(widget.path + '/' + fileName);

      final fileData = await fileRef.getData();  // ファイルのデータを取得

      if (fileData != null) {
        return utf8.decode(fileData);  // バイトデータをUTF-8でデコードして文字列を返す
      } else {
        throw Exception('ファイルが見つかりません');
      }
    } catch (e) {
      throw Exception('Markdownファイルの読み込みに失敗しました: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final userAuth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(repoName != null && ownerName != null
            ? "$repoName by $ownerName"
            : 'Loading...'),
      ),
      drawer: (repoName != null && ownerName != null &&widget.path.isEmpty && userAuth.currentUser!=null && repoMode==1)
      ? Drawer(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 80,
              child: DrawerHeader(
                child: Text('設定とアクティビティ'),
                decoration: BoxDecoration(
                  color: Color(0xFFC5D8E7),
                ),
              ),
            ),
            ListTile(
              title: Text('ログアウト'),
              onTap: () async {
                //アカウントからぬける
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("ログアウト"),
                    content: Text("ログアウトしてもよろしいですか？"),
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
                  //ログアウト時に表示しているユーザ名初期化

                  await FirebaseAuth.instance.signOut();
                  while (FirebaseAuth.instance.currentUser != null) {
                    await Future.delayed(Duration(milliseconds: 100));
                  }
                  print('ログアウト後のユーザー情報: ${userAuth.currentUser}');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Checkuser(userId: userId,repoId: widget.repoId,)),
                        (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ): null, // repoNameまたはownerNameがnullの場合、Drawerを表示しない
      body: Container(
        margin: EdgeInsets.only(
          top: 50,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // リポジトリ名とオーナー名の表示
                  Text(
                    "$repoName by $ownerName",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // 戻るボタンの表示（必要な場合）
                  if (widget.path.isNotEmpty)
                    _backFile(),
                  // ファイルとフォルダのリストを表示
                  ...content.map((item) => _FolderOrFile(item)).toList(),
                  SizedBox(height: 20),
                  // マークダウンウィジェットの表示
                  _buildMarkdownWidget(),
                ],
              ),
      ),
    );
  }

  // マークダウンウィジェットを作成する関数
Widget _buildMarkdownWidget() {
  if (content.any((file) => file.endsWith('.md'))) {
    final markdownFile = content.firstWhere((file) => file.endsWith('.md'));

    return FutureBuilder<String>(
      future: _loadMarkdownFile(markdownFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Markdownファイルの読み込みに失敗しました: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null && (snapshot.data as String).isNotEmpty) {
          return Container(
            color: Colors.black, // 背景を黒に設定
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: Markdown(
              data: snapshot.data as String,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // 内部のスクロールを無効化
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(color: Colors.white),
                h1: TextStyle(color: Colors.white),
                h2: TextStyle(color: Colors.white),
                h3: TextStyle(color: Colors.white),
                h4: TextStyle(color: Colors.white),
                h5: TextStyle(color: Colors.white),
                h6: TextStyle(color: Colors.white),
                strong: TextStyle(color: Colors.white),
                em: TextStyle(color: Colors.white),
                code: TextStyle(color: Colors.white, backgroundColor: Colors.grey[800]),
                codeblockDecoration: BoxDecoration(color: Colors.grey[800]),
                blockquote: TextStyle(color: Colors.white),
                listBullet: TextStyle(color: Colors.white),
                // 他のスタイルも必要に応じて設定
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  } else {
    return SizedBox.shrink();
  }
}



  Widget _FolderOrFile(String itemName) {
    if (itemName.endsWith('/')) {
      return _FolderItem(itemName);
    } else {
      return _FileItem(itemName);
    }
  }


  Widget _FolderItem(String folderName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepositoryScreen(
                      repoId: widget.repoId,
                      path: widget.path + '/' + folderName,
                    ),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(folderName, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _FileItem(String fileName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileScreen(
                        repoId: widget.repoId,
                        path: widget.path + '/' + fileName,
                      ),
                    ),
                  );
                },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(fileName, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backFile() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("..", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
