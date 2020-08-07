import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Int32Max = 2147483647;
const GitHubPage = "https://github.com/thuhole/webhole-next";
const THUHOLE_API_BASE = "https://thuhole.com/services/thuhole";
const THUHOLE_IMAGE_BASE = "https://thimg.yecdn.com/";
const PKUHOLE_API_BASE = "https://pkuhelper.pku.edu.cn/services/pkuhole";
const PKUHOLE_IMAGE_BASE =
    "https://pkuhelper.pku.edu.cn/services/pkuhole/images/";

const BASE64_RATE = 4 / 3;
const MAX_IMG_DIAM = 8000;
const MAX_IMG_PX = 5000000;
//const MAX_IMG_FILESIZE = 450000 * BASE64_RATE;

const FOLD_TAGS = [
  '性相关',
  '政治相关',
  '性话题',
  '政治话题',
  '折叠',
  'NSFW',
  '刷屏',
  '真实性可疑',
  '用户举报较多',
  '举报较多',
  '重复内容',
];

enum HoleType { p, t }

extension HoleTypeExtension on HoleType {
  String name() {
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
//  return type == HoleType.p
//      ? Color.fromRGBO(139, 0, 18, 1)
//      : Color.fromRGBO(102, 8, 116, 1);
  return type == HoleType.p ? Colors.red[400] : Colors.purple[400];
}

String getImageBase(HoleType type) {
  return type == HoleType.p ? PKUHOLE_IMAGE_BASE : THUHOLE_IMAGE_BASE;
}

Color primaryColor = Colors.amber;
Color secondaryColor = Colors.blueAccent;
Color backgroundColor = Colors.grey[50];
final Color pkuRed = Color.fromRGBO(139, 0, 18, 1);
final Color thuPurple = Color.fromRGBO(102, 8, 116, 1);

void initColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int pColorInt = prefs.getInt("primaryColor");
  int sColorInt = prefs.getInt("secondaryColor");
  int bColorInt = prefs.getInt("backgroundColor");
  if (pColorInt != null) primaryColor = Color(pColorInt);
  if (sColorInt != null) secondaryColor = Color(sColorInt);
  if (bColorInt != null) backgroundColor = Color(bColorInt);
}
