import 'package:flutter/material.dart';

//Drawerでのユーザ名の変更を感知して他のページにわたす
class AppUserProvider with ChangeNotifier {
  //ユーザ名のデフォルト値
  String _username = '{Username}';

  String get username => _username;

  void setUsername(String username) {
    _username = username;
    notifyListeners(); // 状態が変わったことを通知する
  }
  void reset() {
    _username = '{Username}';
    notifyListeners(); // 変更を通知
  }
}
