import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/resetpasswd.dart';

import '../../config/size_config.dart';
import '../repository.dart';

class Checkuser extends StatefulWidget {
  final userId;
  final repoId;
  const Checkuser({
    super.key,
    this.userId,
    this.repoId});

  @override
  State<Checkuser> createState() => _CheckuserState();
}

class _CheckuserState extends State<Checkuser> {
  bool _isObscure = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final userAuth = FirebaseAuth.instance;

  GithubAuthProvider githubProvider = GithubAuthProvider();

  Future _signInWithGitHub() async {
    await FirebaseAuth.instance.signInWithPopup(githubProvider);
    if(userAuth.currentUser!.uid==widget.userId){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RepositoryScreen(repoId: widget.repoId, path: '')));
    }
  }
  //sign in 用のmethod
  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      await userAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if(userAuth.currentUser!.uid==widget.userId){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RepositoryScreen(repoId: widget.repoId, path: '')));

      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } catch (e) {
      return print("error:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Unlistedbin CheckUser"),
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
                        //email 用のTextfield
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
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                          ),
                          onSaved: (String? value) {
                            // 前後の空白を削除して保存
                            email = value!.trim();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'メールアドレスは必須項目です';
                            }
                            //正規表現チェック
                            String emailPattern =
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            RegExp regex = RegExp(emailPattern);
                            if (!regex.hasMatch(value.trim())) {
                              return '正しいメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        //password 用のTextfield
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
                            // 前後の空白を削除して保存
                            password = value!.trim();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'パスワードは必須項目です';
                            } else if (value.length < 6) {
                              return 'パスワードは6桁以上です';
                            }
                            // 記号が含まれていないか確認
                            String specialCharPattern = r'[!@#\$&*~]';
                            RegExp specialCharRegex =
                            RegExp(specialCharPattern);
                            if (specialCharRegex.hasMatch(value)) {
                              return 'パスワードに記号を含めないでください';
                            }
                            // 英字と数字が含まれているか確認
                            String passwordPattern =
                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
                            RegExp regex = RegExp(passwordPattern);
                            if (!regex.hasMatch(value.trim())) {
                              return 'パスワードは英字と数字の両方を含む必要があります';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        //Sign in ボタン
                        ElevatedButton(
                          onPressed: () async {
                            //sign in押されたら -> firebase使ってsign in
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await _signIn(context, email, password);
                            }
                          },
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              //ボタンの文字色
                              color: Color(0xFF02607E),
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            //背景色
                              backgroundColor: Colors.white),
                        ),
                        SizedBox(height: 30),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return Resetpasswd();
                              },
                            ));
                          },
                          child: Text(
                            'Forget password?',
                            style: TextStyle(
                              color: Color(0xFF0500FF),
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
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
                              print("githubでsign in出来ません:$e");
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
