import 'package:flutter/material.dart';
import 'package:for_gdsc_2024/view/components/mypage_appbar.dart';
import 'package:for_gdsc_2024/view/components/mypage_drawer.dart';

class RepositoryScreen extends StatelessWidget {
  final String repoId;
  final String path;
  List<String> content = ['テスト', 'a.txt', 'flutter.csv', 'ファイル'];
  bool isLoading = false;

  // コンストラクタでリポジトリIDを受け取る
  RepositoryScreen({required this.repoId, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        margin: EdgeInsets.only(
          top: 50,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部の名前表示
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            // リストビューでレポジトリ名を表示
            else
              Expanded(
                child: ListView.builder(
                  itemCount: content.length,
                  itemBuilder: (context, index) {
                    return _FolderOrFile(content[index], index); // リポジトリ名を表示
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // リポジトリアイテムのウィジェットを作成するヘルパーメソッド
  Widget _FolderOrFile(String repoName, int index) {
    if (repoName.contains('.')) {
      return _FileItem(repoName, index);
    } else {
      return _FolderItem(repoName, index);
    }
  }

  Widget _FolderItem(String repoName, int index) {
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
                  // リポジトリが選択されたときの処理
               },
              child: Align(
                alignment: Alignment.centerLeft, // テキストを左寄せ
                child: Text(repoName, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _FileItem(String repoName, int index) {
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
                  // リポジトリが選択されたときの処理
               },
              child: Align(
                alignment: Alignment.centerLeft, // テキストを左寄せ
                child: Text(repoName, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}