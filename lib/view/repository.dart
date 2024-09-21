import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repoName != null && ownerName != null
            ? "$repoName by $ownerName"
            : 'Loading...'),
      ),
      body: Container(
        margin: EdgeInsets.only(
          top: 50,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$repoName by $ownerName", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: widget.path.isEmpty ? content.length : content.length + 1,
                  itemBuilder: (context, index) {
                    if (widget.path.isNotEmpty && index == 0) {
                      return _backFile();
                    } else {
                      final contentIndex = widget.path.isEmpty ? index : index - 1;
                      return _FolderOrFile(content[contentIndex], contentIndex);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _FolderOrFile(String itemName, int index) {
    if (itemName.endsWith('/')) {
      return _FolderItem(itemName, index);
    } else {
      return _FileItem(itemName, index);
    }
  }

  Widget _FolderItem(String folderName, int index) {
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

  Widget _FileItem(String fileName, int index) {
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
              onPressed: () {},
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
