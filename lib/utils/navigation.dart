import 'package:flutter/cupertino.dart';

class AppNavigation {

  static Future<void> NavigationPush(BuildContext context, Widget page) async{
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  static Future<void> NavigationPushReplacement(BuildContext context, Widget page) async{
    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => page));
  }

  static Future<void> NavigationAndRemoveUntil(BuildContext context, Widget page, Widget target) async{
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => page), (Route<dynamic> route) => false,);
  }

  static Future<void> NavigationBack(BuildContext context) async{
    Navigator.pop(context);
  }
}