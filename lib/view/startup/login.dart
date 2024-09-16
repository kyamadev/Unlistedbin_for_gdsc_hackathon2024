import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("AppName"),
      ),
    );
  }
}
