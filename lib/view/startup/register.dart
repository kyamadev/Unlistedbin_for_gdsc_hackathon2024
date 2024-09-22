import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/login.dart';

import '../../config/size_config.dart';
import '../../model/appuser.dart';
import '../mypage/mypage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String displayname = "";
  String email = "";
  String password = "";
  String passwdConfirm = "";
  bool _isObscure = true;
  bool _isObscureConfirm = true;

  TextEditingController _displaynameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwdConfirmController = TextEditingController();

  final userAuth = FirebaseAuth.instance;

  //githubでsign in,sign up
  Future _signInWithGitHub() async {
    try {
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(githubProvider);

      // ユーザー情報を取得
      final User? user = userCredential.user;
      if (user != null) {
        final String? username = user.displayName;
        print('GitHub ユーザー名: $username');

        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDocRef.set({
          'username': user.displayName,
          'email': user.email,
          'created_at': DateTime.now()
        });
      }
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Mypage()), (_) => false);
    } catch (e) {
      print('GitHub ログインエラー: $e');
    }
  }

  //新規ユーザ情報登録用
  final AppUser _newUser = AppUser();

  //sign up 用のmethod
  Future<void> _createUser(
      BuildContext context, String email, String password) async {
    try {
      // Firebase Authentication にユーザーを作成
      UserCredential userCredential = await userAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firestore のドキュメントリファレンスを取得（ユーザーIDを基に保存先を決定）
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);

      // Firestore にユーザー情報を保存
      _newUser.username = _displaynameController.text;
      _newUser.email = _emailController.text;
      _newUser.created_at = DateTime.now();

      await _setUser(userDocRef);

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Mypage()), (_) => false);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
    }
  }

  //user情報をfirebaseに格納する
  Future<void> _setUser(DocumentReference _mainReference) async {
    try {
      _formKey.currentState!.save();
      await _mainReference.set({
        'username': _newUser.username,
        'email': _newUser.email,
        'created_at': _newUser.created_at
      });
      Fluttertoast.showToast(msg: "ユーザ情報の保存に成功しました");
    } catch (e) {
      Fluttertoast.showToast(msg: "ユーザ情報の保存に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Unlistedbin"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              //幅-> 画面幅の60%
              width: SizeConfig.blockSizeHorizontal! * 50,
              color: Color(0xFF006788),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _displaynameController,
                          decoration: InputDecoration(
                            labelText: 'Display name',
                            filled: true,
                            fillColor: Colors.white,
                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                          ),
                          onSaved: (String? value) {
                            displayname = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '名前は必須項目です';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Mail Address',
                            filled: true,
                            fillColor: Colors.white,

                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                          ),
                          onSaved: (String? value) {
                            email = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'メールアドレスは必須項目です';
                            }
                            //正規表現チェック
                            String emailPattern =
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            RegExp regex = RegExp(emailPattern);
                            if (!regex.hasMatch(value)) {
                              return '正しいメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          obscureText: _isObscure,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              // 文字の表示・非表示でアイコンを変える
                              icon: Icon(_isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              // アイコンがタップされたら現在と反対の状態をセットする
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),

                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                          ),
                          onSaved: (String? value) {
                            password = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'パスワードは必須項目です';
                            } else if (value.length < 6) {
                              return 'パスワードは6桁以上です';
                            }
                            // 記号を含むパターンにドットも追加
                            String specialCharPattern = r'[!@#\$&*~.]';
                            RegExp specialCharRegex = RegExp(specialCharPattern);

                            // 英字、数字、記号（.を含む）のいずれかが含まれるか確認
                            String passwordPattern = r'^(?=.*[A-Za-z]|.*\d|.*[!@#\$&*~.])[A-Za-z\d!@#\$&*~.]{6,}$';
                            RegExp regex = RegExp(passwordPattern);

                            if (!regex.hasMatch(value.trim())) {
                              return 'パスワードは英字、数字、記号（.も含む）のいずれかを含む必要があります';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          obscureText: _isObscureConfirm,
                          controller: _passwdConfirmController,
                          decoration: InputDecoration(
                            labelText: 'Password(Confirm)',
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              // 文字の表示・非表示でアイコンを変える
                              icon: Icon(_isObscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              // アイコンがタップされたら現在と反対の状態をセットする
                              onPressed: () {
                                setState(() {
                                  _isObscureConfirm = !_isObscureConfirm;
                                });
                              },
                            ),

                            //入力に問題があるとき -> 入力欄の周りが赤くなる
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                          ),
                          onSaved: (String? value) {
                            passwdConfirm = value!;
                          },
                          validator: (value) {
                            if (passwdConfirm != password) {
                              return 'パスワードが一致しません';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            //sign in押されたら -> firebase使ってsign in
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await _createUser(context, email, password);
                            }
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              //ボタンの文字色
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              //背景色
                              backgroundColor: Color(0xFF00413E)),
                        ),

                        SizedBox(height: 30),
                        Text(
                          "Or with",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),

                        //github ログイン用画像
                        GestureDetector(
                          child: Image.asset('images/github_mark.png'),
                          onTap: () async {
                            try {
                              await _signInWithGitHub();
                            } catch (e) {
                              print("githubでsign up出来ません:$e");
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        //白い線
                        Container(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Already have account?",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10),
                            TextButton(
                              child: Text("Sign in",
                                  style: TextStyle(
                                    color: Color(0xFF0500FF),
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  )),
                              onPressed: () {
                                //sign up押されたら -> 新規登録
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Login();
                                    },
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
