import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/login.dart';

import '../../config/size_config.dart';
import '../mypage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}


class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey= GlobalKey<FormState>();
  String displayname="";
  String email="";
  String password="";
  String passwdConfirm="";

  TextEditingController _displaynameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwdConfirmController = TextEditingController();


  final userAuth =FirebaseAuth.instance;

  GithubAuthProvider githubProvider = GithubAuthProvider();

  //githubでsign in,sign up
  Future _signInWithGitHub() async {
    await FirebaseAuth.instance.signInWithPopup(githubProvider);
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => Mypage()),(_) => false);
  }

  //sign up 用のmethod
  Future<void> _createUser(BuildContext context, String email, String password) async {
    try {
      await userAuth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => Mypage()),(_) => false);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("AppName"),
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
                        SizedBox(height: 30,),
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
                          onSaved: (String? value){
                            displayname=value!;
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return '名前は必須項目です';
                            }else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30,),
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
                          onSaved: (String? value){
                            email=value!;
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return 'メールアドレスは必須項目です';
                            }else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                          onSaved: (String? value){
                            password=value!;
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return 'パスワードは必須項目です';
                            }else if(value.length<6){
                              return 'パスワードは6桁以上です';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _passwdConfirmController,
                          decoration: InputDecoration(
                            labelText: 'Password(Confirm)',
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
                          onSaved: (String? value){
                            passwdConfirm=value!;
                          },
                          validator: (value){
                            if(passwdConfirm!=password){
                              return 'パスワードが一致しません';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async{
                            //sign in押されたら -> firebase使ってsign in
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              await _createUser(context, email, password);
                            }
                          },
                          child: Text("Sign up", style: TextStyle(
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
                              backgroundColor: Color(0xFF00413E)
                          ),
                        ),

                        SizedBox(height: 30),
                        Text("Or with", style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),),

                        //github ログイン用画像
                        GestureDetector(
                          child: Image.asset('images/github_mark.png'),
                          onTap: () async{
                            try{
                              await _signInWithGitHub();
                            }catch(e) {
                              print("githubでsign up出来ません:$e");
                            }
                          },),
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
                            Text("Already have account?", style: TextStyle(
                                color: Colors.white,
                                fontSize: 20
                            ),),
                            SizedBox(width: 10),
                            TextButton(
                              child: Text("Sign in", style: TextStyle(color: Color(0xFF0500FF),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,)),
                              onPressed: (){
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
        )
    );
  }
}
