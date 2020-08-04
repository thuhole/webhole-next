import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String UA = "webhole-flutter";
const THUHOLE_API_BASE = "https://thuhole.com/services/thuhole";
const THUHOLE_IMAGE_BASE = "https://thimg.yecdn.com/";
Color primaryColor = Colors.amber;
Color secondaryColor = Colors.green;

void initColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int pColorInt = prefs.getInt("primaryColor");
  int sColorInt = prefs.getInt("secondaryColor");
  if (pColorInt != null) primaryColor = Color(pColorInt);
  if (sColorInt != null) secondaryColor = Color(sColorInt);
}
