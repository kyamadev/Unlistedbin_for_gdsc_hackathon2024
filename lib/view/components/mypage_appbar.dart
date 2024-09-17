import 'package:flutter/material.dart';

// マイページ用のカスタムAppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
    const CustomAppBar({Key? key}) : super(key: key);
    final String username = '{Username}';

    @override
    Widget build(BuildContext context) {
    return AppBar(
        title: Text('AppName'), 
        actions: [
        Container(
            width: 160,
            height: 60,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
            child: Text(
                '$username', 
                style: TextStyle(
                color: Color(0xFF02607E),
                fontSize: 30,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.0,
                ),
            ),
            ),
        ),
        ],
    );
    }

    // `PreferredSizeWidget` を実装するために `preferredSize` をオーバーライド
    @override
    Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
