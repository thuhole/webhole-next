import 'package:shared_preferences/shared_preferences.dart';

Future<String> tokenParams() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token');
  return '&user_token=' + token;
}
