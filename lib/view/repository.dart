import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RepositoryScreen extends StatefulWidget {
  final String repoId;
  final String path;

  // コンストラクタでリポジトリIDとパスを受け取る
  const RepositoryScreen({super.key, required this.repoId, required this.path});

  @override
  State<RepositoryScreen> createState() => _RepositoryState();
}

class _RepositoryState extends State<RepositoryScreen> {
  List<String> content = [];
  bool isLoading = true;
  late String userId; 

  @override
  void initState() {
    super.initState();
    _findUserId();
    _fetchFiles();
  }

  // Firebase Storageからファイルリストを取得するメソッド
  Future<void> _fetchFiles() async {
    try {
      final storageRef = FirebaseStorage.instance.ref('repositories').child(userId).child(widget.repoId).child(widget.path);
      final listResult = await storageRef.listAll(); // フォルダ内の全ファイルとフォルダを取得

      List<String> fileNames = [];
      // ファイルを取得してリストに追加
      for (var item in listResult.items) {
        fileNames.add(item.name); // ファイル名をcontentリストに追加
      }

      // フォルダも表示したい場合
      for (var prefix in listResult.prefixes) {
        fileNames.add(prefix.name + '/'); // フォルダ名をcontentリストに追加
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
          timeInSecForIosWeb: 5);
      setState(() {
        isLoading = false;
      });
    }
  }

  // ユーザIDを取得するメソッド
  void _findUserId() {
    userId = "FlmnZfICK1SWUFAYXTcjdrGM3P62"; // 仮のユーザID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("リポジトリ内容")),
      body: Container(
        margin: EdgeInsets.only(
          top: 50,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("{reponame} by {ownername}", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
             Expanded(
              child: ListView.builder(
                itemCount: widget.path.isEmpty ? content.length : content.length + 1,  // 「..」を表示するかしないか
                itemBuilder: (context, index) {
                  if (widget.path.isNotEmpty && index == 0) {
                    // 「..」を表示 (pathが空でない場合)
                    return _backFile();
                  } else {
                    // それ以外のアイテムを表示
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

  // リポジトリアイテムのウィジェットを作成するヘルパーメソッド
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
                // フォルダが選択されたときの処理
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
                alignment: Alignment.centerLeft, // テキストを左寄せ
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
              onPressed: () {
                // ファイルが選択されたときの処理
              },
              child: Align(
                alignment: Alignment.centerLeft, // テキストを左寄せ
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
                // フォルダが選択されたときの処理
                 Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.centerLeft, // テキストを左寄せ
                child: Text("..", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
