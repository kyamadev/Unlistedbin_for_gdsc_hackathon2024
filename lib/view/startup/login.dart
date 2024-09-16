import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:for_gdsc_2024/view/startup/register.dart';

import '../../config/size_config.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey= GlobalKey<FormState>();
  String email="";
  String password="";

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final userAuth =FirebaseAuth.instance;

  //sign in 用のmethod
  Future<void> _signIn(BuildContext context,String email,String password) async{
    try{
      await userAuth.signInWithEmailAndPassword(email: email, password: password);
      /*Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => Navigation()),(_) => false);*/
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
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
                      SizedBox(height: 100,),
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
                      ElevatedButton(
                        onPressed: () async{
                        //sign in押されたら -> firebase使ってsign in
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await _signIn(context, email, password);
                          }
                        },
                        child: Text("Sign in",
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
                            backgroundColor: Colors.white
                        ),
                      ),
                      SizedBox(height: 30),
                      Text('Forget password?', style: TextStyle(color: Color(0xFF0500FF),
                        fontSize: 30,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0,),
                      ),
                      SizedBox(height: 30),
                      Text("Or with", style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),),

                      //github ログイン用画像
                      Image.asset('images/github_mark.png'),
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
                          Text("Make new account?", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                          ),),
                          SizedBox(width: 10),
                          TextButton(
                            child: Text("Sign up", style: TextStyle(color: Color(0xFF0500FF),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 0,)),
                            onPressed: (){
                              //sign up押されたら -> 新規登録
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Register();
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
