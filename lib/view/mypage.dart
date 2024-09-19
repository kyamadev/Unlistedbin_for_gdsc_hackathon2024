import 'package:flutter/material.dart';
import 'package:for_gdsc_2024/view/components/mypage_appbar.dart';

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        margin: EdgeInsets.only(
          top: 50,
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部のボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ボックスを開く
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildCustomDialog(context);
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                      ),
                    ),
                  child: Text(
                      'Upload',
                      style: TextStyle(
                        color: Color(0xFF02607E),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // リストビュー
            Expanded(
              child: ListView(
                children: [
                  _buildRepoItem('repo_A'),
                  _buildRepoItem('repo_B'),
                  _buildRepoItem('repo_C'),
                  // 追加のリポジトリアイテムをここに追加
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // リポジトリアイテムのウィジェットを作成するヘルパーメソッド
  Widget _buildRepoItem(String repoName) {
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
            child: Text(repoName, style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: Icon(Icons.content_paste, color: Colors.white),
            onPressed: () {
              // クリップボードボタンが押されたときの処理
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // 設定ボタンが押されたときの処理
            },
          ),
        ],
      ),
    );
  }
  
  // カスタムダイアログのウィジェット
  Widget _buildCustomDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ダイアログのヘッダー（バツボタン）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('作成するレポジトリの名前を記入してください', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // Inputボックス
            TextField(
              decoration: InputDecoration(
                labelText: 'レポジトリ名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // 作成ボタン
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // 作成ボタンが押されたときの処理
                  Navigator.of(context).pop();
                },
                child: Text('作成'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
