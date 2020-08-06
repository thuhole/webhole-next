import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:webhole/utils.dart';

import 'config.dart';

abstract class HoleFetcher {
  void reset();

  Future<List<dynamic>> fetch();
}

abstract class OneTypeHoleFetcher extends HoleFetcher {
  HoleType getType();
}

class SearchPostsFetcher extends OneTypeHoleFetcher {
  dynamic lastData;
  String keywords;
  int page = 1;
  HoleType type;

  SearchPostsFetcher(this.type, this.keywords);

  HoleType getType() {
    return this.type;
  }

  void reset() {
    page = 1;
  }

  Future<List<dynamic>> fetch() async {
    String token = await type.getToken();
    if (!isValidToken(token)) {
      throw Exception(type.name() + "尚未登录");
    }
    print("fetch search page " + page.toString());
    final resp = await http.get(
        type.getApiBase() +
            "/api.php?action=search&pagesize=50&PKUHelperAPI=3.0&keywords=" +
            keywords +
            "&page=" +
            page.toString() +
            tokenParams(token),
        headers: {});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(type.name() + j["msg"]);
      }
      List<dynamic> data = j["data"];

      List<dynamic> rtn = [];
      for (dynamic item in data) {
        item["timestamp"] = int.parse(item["timestamp"].toString());
        item["pid"] = int.parse(item["pid"].toString());
        item["reply"] = int.parse(item["reply"].toString());
        item["likenum"] = int.parse(item["likenum"].toString());
        if (page == 1 || lastData["timestamp"] > item["timestamp"]) {
          item["holeType"] = type;
          rtn.add(item);
        }
      }
      if (data.length > 0) lastData = data[data.length - 1];
      page += 1;
      return rtn;
    } else {
      throw Exception(type.name() + 'HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class PostsFetcher extends OneTypeHoleFetcher {
  dynamic lastData;
  int page = 1;
  HoleType type;

  PostsFetcher(this.type);

  HoleType getType() {
    return this.type;
  }

  void reset() {
    page = 1;
  }

  Future<List<dynamic>> fetch() async {
    String token = await type.getToken();
    if (!isValidToken(token)) {
      throw Exception(type.name() + "尚未登录");
    }
    print("fetch page " + page.toString());
    final resp = await http.get(
        type.getApiBase() +
            "/api.php?action=getlist&PKUHelperAPI=3.0&p=" +
            page.toString() +
            tokenParams(token),
        headers: {});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(type.name() + j["msg"]);
      }
      List<dynamic> data = j["data"];

      List<dynamic> rtn = [];
      for (dynamic item in data) {
        item["timestamp"] = int.parse(item["timestamp"].toString());
        item["pid"] = int.parse(item["pid"].toString());
        item["reply"] = int.parse(item["reply"].toString());
        item["likenum"] = int.parse(item["likenum"].toString());
        if (page == 1 || lastData["timestamp"] > item["timestamp"]) {
          item["holeType"] = type;
          rtn.add(item);
        }
      }
      if (data.length > 0) lastData = data[data.length - 1];
      page += 1;
      return rtn;
    } else {
      throw Exception(type.name() + 'HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class OneHoleFetcher extends OneTypeHoleFetcher {
  HoleType type;
  int page = 1;
  String pid;

  OneHoleFetcher(this.type, this.pid);

  HoleType getType() {
    return this.type;
  }

  void reset() {
    page = 1;
  }

  Future<List<dynamic>> fetch() async {
    String token = await type.getToken();
    if (!isValidToken(token)) {
      throw Exception(type.name() + "尚未登录");
    }
    if (page != 1) {
      return [];
    }
    final resp = await http.get(
        type.getApiBase() +
            "/api.php?action=getone&pid=" +
            pid +
            "&PKUHelperAPI=3.0" +
            tokenParams(token),
        headers: {});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(type.name() + j["msg"]);
      }
      dynamic item = j["data"];
      item["timestamp"] = int.parse(item["timestamp"].toString());
      item["pid"] = int.parse(item["pid"].toString());
      item["reply"] = int.parse(item["reply"].toString());
      item["likenum"] = int.parse(item["likenum"].toString());
      item["holeType"] = type;
      page += 1;
      return [item];
    } else {
      throw Exception(type.name() + 'HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class AttentionFetcher extends OneTypeHoleFetcher {
  int page = 1;
  HoleType type;

  AttentionFetcher(this.type);

  HoleType getType() {
    return this.type;
  }

  void reset() {
    page = 1;
  }

  Future<List<dynamic>> fetch() async {
    String token = await type.getToken();
    if (!isValidToken(token)) {
      throw Exception(type.name() + "尚未登录");
    }
    if (page != 1) {
      return [];
    }
    final resp = await http.get(
        type.getApiBase() +
            "/api.php?action=getattention&PKUHelperAPI=3.0" +
            tokenParams(token),
        headers: {});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(type.name() + j["msg"]);
      }
      page += 1;
      List<dynamic> data = j["data"];
      List<dynamic> rtn = [];
      for (dynamic item in data) {
        item["timestamp"] = int.parse(item["timestamp"].toString());
        item["pid"] = int.parse(item["pid"].toString());
        item["reply"] = int.parse(item["reply"].toString());
        item["likenum"] = int.parse(item["likenum"].toString());
        item["holeType"] = type;
        rtn.add(item);
      }
      return rtn;
    } else {
      throw Exception(type.name() + 'HTTP异常代码' + resp.statusCode.toString());
    }
  }
}

class MergedHoleFetcher extends HoleFetcher {
  List<OneTypeHoleFetcher> fetchers;
  List<bool> enabled;
  List<List<dynamic>> fetchersResults;
  List<int> fetcherTimestamps;
  int currentTimestamp;
  int length;

  bool resetting = false;

  MergedHoleFetcher(List<OneTypeHoleFetcher> fetchers) {
    if (fetchers.length == 0) {
      throw Exception("No fetcher!");
    }
    this.fetchers = fetchers;
    this.reset();
  }

  Future<int> enabledCount() async {
    int rtn = 0;
    enabled = [];
    for (int i = 0; i < length; i++) {
      String token = await fetchers[i].getType().getToken();
      if (!isValidToken(token))
        enabled.add(false);
      else {
        enabled.add(true);
        rtn += 1;
      }
    }
    return rtn;
  }

  Future<List> fetch() async {
    if (await enabledCount() == 0) throw Exception("尚未登录");

    List<dynamic> rtn = [];
    for (int i = 0; i < length; i++) {
      if (fetcherTimestamps[i] == currentTimestamp && enabled[i]) {
        await _updateFetcher(i);
      }
    }
    currentTimestamp = fetcherTimestamps.reduce(max);
    for (int i = 0; i < length; i++) {
      if (!enabled[i]) continue;
      for (dynamic item in fetchersResults[i]) {
        if (item["timestamp"] >= currentTimestamp) {
          item["color"] = await this.enabledCount() == 1
              ? primaryColor
              : getHoleTypeColor(item["holeType"]);
          rtn.add(item);
        }
      }
      fetchersResults[i]
          .removeWhere((item) => item["timestamp"] >= currentTimestamp);
    }
    rtn.sort((a, b) => b["timestamp"] - a["timestamp"]);

    return rtn;
  }

  Future<void> _updateFetcher(int index) async {
    List<dynamic> results = [];
    try {
      results = await fetchers[index].fetch();
    } catch (e) {
      showErrorToast(e.toString());
    }
    fetchersResults[index].addAll(results);
    fetcherTimestamps[index] =
        results.length > 0 ? results[results.length - 1]["timestamp"] : -1;
  }

  Future<void> reset() async {
    if (this.resetting == true) return;
    resetting = true;
    for (OneTypeHoleFetcher fetcher in fetchers) {
      fetcher.reset();
    }
    this.length = fetchers.length;
    fetcherTimestamps = [];
    fetchersResults = [];
    for (int i = 0; i < length; i++) {
      String token = await fetchers[i].getType().getToken();
      if (!isValidToken(token)) {
        fetcherTimestamps.add(-1);
      } else {
        fetcherTimestamps.add(Int32Max);
      }
      fetchersResults.add([]);
    }
    currentTimestamp = Int32Max;
    resetting = false;
  }
}

class CommentFetcher {
  HoleType type;

  CommentFetcher(this.type);

  Future<List<dynamic>> fetch(int pid) async {
    String token = await type.getToken();
    if (!isValidToken(token)) {
      throw Exception(type.name() + "尚未登录");
    }
    final resp = await http.get(
        type.getApiBase() +
            "/api.php?action=getcomment&PKUHelperAPI=3.0&pid=" +
            pid.toString() +
            tokenParams(token),
        headers: {});
    if (resp.statusCode == 200) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) {
        throw Exception(type.name() + j["msg"]);
      }
      List<dynamic> data = j["data"];
      List<dynamic> rtn = [];
      for (dynamic item in data) {
        item["timestamp"] = int.parse(item["timestamp"].toString());
        item["pid"] = int.parse(item["pid"].toString());
        item["cid"] = int.parse(item["cid"].toString());
        item["color"] = secondaryColor;
        item["reply"] = 0;
        item["likenum"] = 0;
        item["holeType"] = type;
        rtn.add(item);
      }
      rtn.sort((a, b) => a["timestamp"] - b["timestamp"]);
      return rtn;
    } else {
      throw Exception(type.name() + 'HTTP异常代码' + resp.statusCode.toString());
    }
  }
}
