import 'package:flutter/material.dart';

import '../../config/size_config.dart';
import '../components/mypage_appbar.dart';
import '../components/mypage_drawer.dart';

class MyPageSetting extends StatefulWidget {
  const MyPageSetting({super.key});

  @override
  State<MyPageSetting> createState() => _MyPageSettingState();
}

class _MyPageSettingState extends State<MyPageSetting> {
  int _privacyVal=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              //幅-> 画面幅の60%
              width: SizeConfig.blockSizeHorizontal! * 60,
              color: Color(0xFF006788),
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Repository name",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      //email 用のTextfield
                      Container(
                          color: Colors.white,
                          child: Text("repo-a",
                            style: TextStyle(color: Colors.black, fontSize: 20),)),
                      SizedBox(height: 30),
                      //password 用のTextfield
                      Text(
                        "Share URL",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Container(
                          color: Colors.white,
                          child: Text("shareurl/url/",
                            style: TextStyle(color: Colors.black, fontSize: 20),)),
                      SizedBox(height: 30),
                      Text(
                        "Privacy",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      //radioボタン unlisted
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _privacyVal,
                            onChanged: (value){
                              setState(() {
                                _privacyVal=value!;
                              });
                            }
                            ),
                          SizedBox(width: 10.0),
                          const Flexible(child: FittedBox(child: Text('Unlisted (anyone with the link can view)',
                            style: TextStyle(color: Colors.white, fontSize: 20),))
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      //radioボタン private
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                              value: 1,
                              groupValue: _privacyVal,
                              onChanged: (value){
                                setState(() {
                                  _privacyVal=value!;
                                });
                              }
                          ),
                          SizedBox(width: 10.0),
                          Flexible(child: FittedBox(child: Text('Private (Share URL or disabled)',
                            style: TextStyle(color: Colors.white, fontSize: 20),),)),
                        ],
                      ),
                      SizedBox(height: 30),
                      //URL再生成 ボタン
                      OutlinedButton(
                        child: const Text('Regenerate URL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:Color(0xff878702),shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(height: 30),
                      //レポジトリ削除 ボタン
                      OutlinedButton(
                        child: const Text('Delete repository'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:Color(0xff870202),shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () {},
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
