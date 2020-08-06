import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Int32Max = 2147483647;
const THUHOLE_API_BASE = "https://thuhole.com/services/thuhole";
const THUHOLE_IMAGE_BASE = "https://thimg.yecdn.com/";
const PKUHOLE_API_BASE = "https://pkuhelper.pku.edu.cn/services/pkuhole";
const PKUHOLE_IMAGE_BASE =
    "https://pkuhelper.pku.edu.cn/services/pkuhole/images/";

enum HoleType { p, t }

extension HoleTypeExtension on HoleType {
  String getStr() {
    return this == HoleType.p ? "pkuhole" : "thuhole";
  }

  String getApiBase() {
    return this == HoleType.p ? PKUHOLE_API_BASE : THUHOLE_API_BASE;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(this == HoleType.t ? 'thuToken' : 'pkuToken');
  }
}

Color getHoleTypeColor(HoleType type) {
  return type == HoleType.p ? Colors.red[400] : Colors.purple[400];
}

String getImageBase(HoleType type) {
  return type == HoleType.p ? PKUHOLE_IMAGE_BASE : THUHOLE_IMAGE_BASE;
}

Color primaryColor = Colors.amber;
Color secondaryColor = Colors.blueAccent;
Color backgroundColor = Colors.grey[50];

void initColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int pColorInt = prefs.getInt("primaryColor");
  int sColorInt = prefs.getInt("secondaryColor");
  int bColorInt = prefs.getInt("backgroundColor");
  if (pColorInt != null) primaryColor = Color(pColorInt);
  if (sColorInt != null) secondaryColor = Color(sColorInt);
  if (bColorInt != null) backgroundColor = Color(bColorInt);
}
