import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webhole/config.dart';

import '../utils.dart';
import 'postWidget.dart';

class ReplyWidget extends StatefulWidget {
  final Function callback;
  final dynamic info;

  ReplyWidget(this.callback, this.info);

  @override
  _ReplyWidgetState createState() =>
      _ReplyWidgetState(this.callback, this.info);
}

class _ReplyWidgetState extends State<ReplyWidget>
    with SingleTickerProviderStateMixin {
  final Function callback;
  final dynamic originalInfo;

  _ReplyWidgetState(this.callback, this.originalInfo);

  Map<String, dynamic> info = {};

  TextEditingController _textController;
  TabController _tabController;

  bool _isSending = false;

  void updatePreviewInfo() {
    info["pid"] = 0;
    info["timestamp"] =
        (new DateTime.now().toUtc().microsecondsSinceEpoch ~/ 1000000);
    info["reply"] = 0;
    info["likenum"] = 0;
    info["color"] = secondaryColor;
    info["holeType"] = HoleType.p;
    info["text"] = "[Nickname] " + _textController.text;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        setState(() {
          updatePreviewInfo();
        });
      }
    });

    RegExp exp = new RegExp(r"^\[(.*)\]");
    String nickName = '';
    if (exp.hasMatch(originalInfo["text"])) {
      nickName = exp.firstMatch(originalInfo["text"]).group(0);
      nickName = nickName.substring(1, nickName.length - 1);
    }
    _textController = TextEditingController(text: 'Re ' + nickName + ': ');
    updatePreviewInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build reply");
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 260
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          primary: false,
          appBar: AppBar(
//          leading: Container(),
            backgroundColor: originalInfo["color"],
//          title: Text("发表树洞"),
            title: TabBar(

              controller: _tabController,
              indicatorColor: originalInfo["color"],
              tabs: <Widget>[
                Tab(
                  child: Text(
                    '编辑',
                  ),
                ),
                Tab(
                  child: Text(
                    '预览',
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(children: [
                    SingleChildScrollView(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 16),
                        controller: _textController,
                        minLines: 3,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '请遵守树洞管理规范' +
                              (originalInfo["holeType"] == HoleType.t
                                  ? '（试行）'
                                  : '') +
                              '，文明发言。',
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: sendComment,
                      color: secondaryColor,
                      child: Text(_isSending ? '正在发送' : '发送',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ]),
              ),
              ListView.builder(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(top: 16.0, bottom: 60.0),
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return PostWidget(
                      this.info,
                      isDetailMode: true,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  sendComment() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });
    HoleType type = originalInfo['holeType'];
    final String token = await type.getToken();
    Map<String, String> body = {
      "text": _textController.text,
      "pid": originalInfo["pid"].toString(),
      "user_token": token
    };
    http
        .post(
            type.getApiBase() +
                "/api.php?action=docomment&PKUHelperAPI=3.0" +
                tokenParams(token),
//            headers: {
//              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
//            },
            body: body)
        .then((resp) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0)
        throw Exception(j["msg"]);
      else {
        Navigator.pop(context);
        callback();
      }
    }).catchError((e) {
      showErrorToast(e.toString());
      setState(() {
        _isSending = false;
      });
    });
  }
}
