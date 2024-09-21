import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/size_config.dart';

class Resetpasswd extends StatefulWidget {
  const Resetpasswd({super.key});

  @override
  State<Resetpasswd> createState() => _ResetpasswdState();
}

class _ResetpasswdState extends State<Resetpasswd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  TextEditingController _emailController = TextEditingController();

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
                          height: 100,
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
                            email = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'メールアドレスは必須項目です';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 30),

                        //password resetボタン
                        ElevatedButton(
                          onPressed: () async {
                            //sign in押されたら -> firebase使ってsign in
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);
                                Fluttertoast.showToast(msg: 'メールを送信しました');
                              } catch (e) {
                                Fluttertoast.showToast(msg: 'メールを送信できませんでした');
                              }
                            }
                          },
                          child: Text(
                            "password reset",
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
