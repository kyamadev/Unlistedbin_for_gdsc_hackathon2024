import 'dart:html' as html; 
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:for_gdsc_2024/view/components/mypage_appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  State<Mypage> createState() => _MypageState();
}


class _MypageState extends State<Mypage> {
  late String userId;  // 現在のユーザーIDを保持
  List<String> repositoryNames = [];  // 取得したリポジトリ名を保持
  bool isLoading = true;  // ローディング状態の管理

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _fetchRepositoriesInRealtime();  // リアルタイムでリポジトリを監視
    }
  }

  // Firestoreからリポジトリ名を取得する
  Future<void> _fetchRepositories() async {
    try {
      // Firestoreのusers/{userId}/repositoriesコレクションからデータを取得
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('repositories')
          .get();

      // 取得したドキュメントからリポジトリ名をリストに追加
      final List<String> repoNames = snapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        repositoryNames = repoNames;
        isLoading = false;  // ローディング完了
      });
    } catch (e) {
      print('リポジトリデータの取得エラー: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchRepositoriesInRealtime() {
    FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('repositories')
      .snapshots()
      .listen((snapshot) {
        final List<String> repoNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
        setState(() {
          repositoryNames = repoNames;
          isLoading = false;
        });
      });
  }

  // フォルダのアップロード後に再読み込み
  Future<void> _uploadFolderAndReload() async {
    // フォルダのアップロード処理
    await _uploadFolder();
    
    // アップロード後にリポジトリリストを再取得
    await _fetchRepositories();
  }

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
                    // フォルダ選択ボックスを開く
                    _uploadFolderAndReload();
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
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: repositoryNames.length,
                  itemBuilder: (context, index) {
                    return _buildRepoItem(repositoryNames[index]);  // リポジトリ名を表示
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // フォルダ選択およびアップロード
  Future<void> _uploadFolder() async {
    // リポジトリIDを乱数で生成（衝突しにくい一意な値にする）
    String repositoryId = DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000000).toString();

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true; // 複数ファイル選択を許可
    uploadInput.setAttribute('webkitdirectory', ''); // フォルダごと選択を有効にする

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        // 最初のファイルからフォルダ名を取得（relativePathを分解）
        String folderName = files.first.relativePath?.split('/')?.first ?? 'default_folder';

        // Repositories コレクションにメタデータを保存
        await _saveRepositoryMetadata(repositoryId, folderName);

        // すべてのファイルをループして処理
        for (var file in files) {
          // 各ファイルの相対パスを使用してフォルダ構造をFirebase Storageに再現
          String relativePath = file.relativePath!;
          String storagePath = 'repositories/$userId/$repositoryId/$relativePath'; 

          // Firebase Storageにファイルをアップロード
          await _uploadFile(file, storagePath);
        }
      }
    });

    uploadInput.click(); // ファイル選択ダイアログを表示
  }

  // Repositories コレクションにメタデータを保存（userのサブコレクション）
  Future<void> _saveRepositoryMetadata(String repositoryId, String folderName) async {
    try {
      // Firestoreにリポジトリメタデータを保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('repositories') 
          .doc(repositoryId) 
          .set({
        'name': folderName, 
        'url_key': null, // URL作成時に必要
        'created_at': Timestamp.now(), 
        'updated_at': Timestamp.now(), 
      });

      print('リポジトリメタデータを保存しました: $repositoryId');
    } catch (e) {
      print('リポジトリメタデータ保存エラー: $e');
    }
  }

  // ファイルをFirebase Storageにアップロード
  Future<void> _uploadFile(html.File file, String storagePath) async {
    try {
      // Firebase Storageの参照を取得（ファイルの相対パスを使用）
      final storageRef = FirebaseStorage.instance.ref(storagePath);
      final uploadTask = storageRef.putBlob(file);

      await uploadTask.whenComplete(() async {
        String downloadUrl = await storageRef.getDownloadURL();
        print('ファイルアップロード完了: ${file.name}, URL: $downloadUrl');
      });
    } catch (e) {
      print('ファイルのアップロード中にエラーが発生しました: $e');
    }
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

}
