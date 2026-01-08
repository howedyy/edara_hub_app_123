import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UIUtils{
static void showLoading(BuildContext context, {bool isDismissible = true}){
  showDialog(
    barrierDismissible: isDismissible,
      context: context,
      builder: (context)=>PopScope(
        canPop: isDismissible,
        child: CupertinoAlertDialog(
            content: Center(
        child: CircularProgressIndicator(),)
            ,),
      )
  );
}

static void hideDialog(BuildContext context){
  Navigator.pop(context);
}

static showMessage(BuildContext context, String message){
  showDialog(
      context: context,
      builder: (context)=> CupertinoAlertDialog(content: Text(message, style:TextStyle(color: Colors.black) ,)
      )
  );
}
static void showToastMessage(String message, Color bgColor){
  Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
}