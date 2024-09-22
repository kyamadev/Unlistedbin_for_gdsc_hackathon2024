import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:for_gdsc_2024/view/startup/login.dart';
import 'package:for_gdsc_2024/view/startup/register.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unlistedbin"),
        actions: [
          ElevatedButton(
            onPressed: () {
              //sign in押されたら -> ログイン画面へ画面遷移
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Login();
                  },
                ),
              );
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
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          //中央寄せ
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'WELCOME!\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 130,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text:
                          '\nUnlistedbinはURLを共有することでレポジトリ内のコードを限定公開できる、レポジトリサービスです。\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w300,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Let’s start!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  //sign up押されたら -> 新規登録
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return Register();
                      },
                    ),
                  );
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
                    //文字の色と背景色
                    backgroundColor: Color(0xFF02607E)),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
