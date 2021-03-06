import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webhole/config.dart';

String tokenParams(String token) {
  return '&user_token=' + token;
}

bool isValidToken(String token) {
  return token != null && token.length == 32;
}

String getDateDiff(int diffValue) {
  int minute = 60;
  int hour = minute * 60;
  int day = hour * 24;
  int month = day * 30;
  int diffMonth = diffValue ~/ month;
  int diffWeek = diffValue ~/ (7 * day);
  int diffDay = diffValue ~/ day;
  int diffHour = diffValue ~/ hour;
  int diffMinute = diffValue ~/ minute;
  String result;

  if (diffValue < 0) {
    return ("");
  }
  if (diffMonth > 1) {
    result = (diffMonth).toString() + "月前";
  } else if (diffWeek > 1) {
    result = (diffWeek).toString() + "周前";
  } else if (diffDay > 1) {
    result = (diffDay).toString() + "天前";
  } else if (diffHour > 1) {
    result = (diffHour).toString() + "小时前";
  } else if (diffMinute > 1) {
    result = (diffMinute).toString() + "分钟前";
  } else {
    result = "不到1分钟之前";
  }
  return result;
}

void showErrorToast(String s) {
  Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

void showInfoToast(String s) {
  Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<int> validTokenCount() async {
  int rtn = 0;
  for (HoleType i in [HoleType.p, HoleType.t]) {
    String token = await i.getToken();
    if (isValidToken(token)) rtn += 1;
  }
  return rtn;
}

Color getTextColor(Color backgroundColor) {
  return Colors.black;
//  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

Color brighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}
