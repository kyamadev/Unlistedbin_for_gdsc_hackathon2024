import 'package:flutter/material.dart';

class RepositoryScreen extends StatelessWidget {
final String repoId;

// コンストラクタでリポジトリIDを受け取る
RepositoryScreen({required this.repoId});

@override
Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
        title: Text('Repository $repoId'),
    ),
    body: Center(
        child: Text(
        'Repo ID: $repoId',
        style: TextStyle(fontSize: 24),
        ),
    ),
    );
}
}