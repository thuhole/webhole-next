import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:webhole/utils.dart';

import 'config.dart';

abstract class _HoleFetcher {
  Future<List<dynamic>> fetch(int page);
}

class PostFetcher extends _HoleFetcher {
  Future<List<dynamic>> fetch(int page) async {
    final resp = await http.get(
        THUHOLE_API_BASE +
            "/api.php?action=getlist&p=" +
            page.toString() +
            await tokenParams(),
        headers: {HttpHeaders.userAgentHeader: UA});
    if (resp.statusCode == 200) {
      return json.decode(resp.body)["data"];
    } else {
      throw Exception('HTTP代码' + resp.statusCode.toString());
    }
  }
}
