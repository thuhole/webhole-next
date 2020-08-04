import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webhole/utils.dart';

import 'config.dart';

abstract class HoleFetcher {
  Future<List<dynamic>> fetch(int page);
}

class PostsFetcher extends HoleFetcher {
  dynamic lastData;

  Future<List<dynamic>> fetch(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('thuToken');
    if (token == null || token.length != 32) {
      throw Exception("尚未登录");
    }
    print("fetch page " + page.toString());
    final resp = await http.get(
        THUHOLE_API_BASE +
            "/api.php?action=getlist&p=" +
            page.toString() +
            await tokenParams(token),
        headers: {HttpHeaders.userAgentHeader: UA});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(j["msg"]);
      }
      List<dynamic> data = j["data"];
      if (page == 1) {
        lastData = data[data.length - 1];
        return data;
      }

      List<dynamic> rtn = [];
      for (dynamic item in data) {
        if (lastData["timestamp"] > item["timestamp"]) {
          rtn.add(item);
        }
      }
      lastData = data[data.length - 1];
      return rtn;
    } else {
      throw Exception('HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class AttentionFetcher extends HoleFetcher {
  Future<List<dynamic>> fetch(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('thuToken');
    if (token == null || token.length != 32) {
      throw Exception("尚未登录");
    }
    if (page != 1) {
      return [];
    }
    final resp = await http.get(
        THUHOLE_API_BASE +
            "/api.php?action=getattention&" +
            page.toString() +
            await tokenParams(token),
        headers: {HttpHeaders.userAgentHeader: UA});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(j["msg"]);
      }
      return j["data"];
    } else {
      throw Exception('HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class CommentFetcher {
  Future<List<dynamic>> fetch(int pid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('thuToken');
    if (token == null || token.length != 32) {
      throw Exception("尚未登录");
    }
    final resp = await http.get(
        THUHOLE_API_BASE +
            "/api.php?action=getcomment&pid=" +
            pid.toString() +
            await tokenParams(token),
        headers: {HttpHeaders.userAgentHeader: UA});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(j["msg"]);
      }
      return j["data"];
    } else {
      throw Exception('HTTP异常代码' + resp.statusCode.toString());
    }
  }
}
