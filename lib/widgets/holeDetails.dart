import 'dart:convert';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:webhole/network.dart';
import 'package:webhole/utils.dart';
import 'package:webhole/widgets/reply.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'postWidget.dart';

class HoleDetails extends StatefulWidget {
  final dynamic info;

  HoleDetails({Key key, this.info}) : super(key: key);

  @override
  HoleDetailsState createState() => HoleDetailsState(this.info);
}

class HoleDetailsState extends State<HoleDetails> {
  dynamic info;
  List<dynamic> _postsList = [];
  TwoPageFetcher _itemFetcher;

  HoleDetailsState(this.info);

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  bool _onError = false;
  bool _reversed = false;
  String errorMsg;

  bool _alreadyAttention = false;
  bool _isSettingAttention = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _initFetcher() {
//    _itemFetcher = CommentFetcher(this.info["holeType"], this.info["pid"]);
    if (info["text"] != null)
      _itemFetcher = TwoPageFetcher(
          this.info["holeType"],
          SavedHoleFetcher(this.info["holeType"], [this.info]),
          CommentFetcher(this.info["holeType"], this.info["pid"]));
    else
      _itemFetcher = TwoPageFetcher(
          this.info["holeType"],
          OneHoleFetcher(this.info["holeType"], this.info["pid"].toString()),
          CommentFetcher(this.info["holeType"], this.info["pid"]));
  }

  @override
  void initState() {
    super.initState();
    _initFetcher();
    _loadMore();
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    if (this.mounted) {
      _isRefreshing = true;
      _initFetcher();
      setState(() {
        _onError = false;
        _hasMore = true;
        _postsList = [];
        _isLoading = false;
        _isSettingAttention = false;
        _loadMore();
      });
    }
  }

  void _loadMore() {
    if (_isLoading) return;
    _isLoading = true;
    if (_itemFetcher.fetcher1.runtimeType == SavedHoleFetcher &&
        _postsList.length == 0) {
      _postsList = (_itemFetcher.fetcher1 as SavedHoleFetcher).fetchNow();
      _itemFetcher.page = 2;
    }
    _itemFetcher.fetch().then((List<dynamic> fetchedList) {
      _isLoading = _isRefreshing = false;
      if (_postsList.length == 1) {
        _alreadyAttention =
            (_itemFetcher.fetcher2 as CommentFetcher).getAttention();
      }
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _postsList.addAll(fetchedList);
        });
      }
    }).catchError((e) {
      _isLoading = _isRefreshing = false;
      _onError = true;
      errorMsg = e.toString();
      print(e);
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _onError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("hole_detail build");
    return Scaffold(
      floatingActionButton: SpeedDial(
        // both default to 16
//        marginRight: 18,
//        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
//        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
//        curve: Curves.bounceIn,
//        overlayColor: Colors.white,
//        overlayOpacity: 0.5,
        backgroundColor: holeSecondaryColor,
//        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(_alreadyAttention ? Icons.star : Icons.star_border),
            backgroundColor: holeSecondaryColor,
            label: _alreadyAttention ? '取消关注' : '关注',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: setAttention,
          ),
          SpeedDialChild(
            child: const Icon(Icons.content_copy),
            backgroundColor: holeSecondaryColor,
            label: '复制全文',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => showErrorToast("Not implemented"),
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: holeSecondaryColor,
            label: '刷新',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: refresh,
          ),
          SpeedDialChild(
            child: const Icon(Icons.sort),
            backgroundColor: holeSecondaryColor,
            label: _reversed ? '顺序' : '逆序',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => {
              setState(() {
                _reversed = !_reversed;
              })
            },
          ),
          SpeedDialChild(
              child: const Icon(Icons.report_problem),
              backgroundColor: Colors.red,
              label: '举报',
//              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => showErrorToast("Not implemented")),
        ],
      ),
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(color: holeBackgroundColor),
              child: _buildPosts()),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                button: true,
                enabled: true,
                excludeSemantics: true,
                child: FloatingActionButton.extended(
                  key: const ValueKey('Back'),
                  onPressed: () {
//                    Navigator.of(context)
//                        .popUntil((route) => route.settings.name == '/');
                    Navigator.pop(context);
                  },
                  icon: const BackButtonIcon(),
                  label: Text(
                    MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  backgroundColor: holeSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosts() {
    ScrollController _rrectController = ScrollController();
    return RefreshIndicator(
      onRefresh: refresh,
      child: DraggableScrollbar(
        controller: _rrectController,
        heightScrollThumb: 48.0,
        backgroundColor: holeSecondaryColor,
        scrollThumbBuilder: buildScrollBar,
        child: ListView.builder(
            controller: _rrectController,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(
                top: 16.0 + MediaQuery.of(context).padding.top, bottom: 60.0),
            itemCount: _hasMore ? _postsList.length + 1 : _postsList.length,
            itemBuilder: (BuildContext context, int index) {
              if (!_onError && !_isLoading && _hasMore) {
                // preload
                _loadMore();
              }
              if (index >= _postsList.length) {
                if (_onError) {
                  return Center(
                    child: Text("Error: " + errorMsg),
                  );
                }
                return Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 32,
                    width: 32,
                  ),
                );
              }

              Map<String, dynamic> tmp =
                  _postsList[_reversed ? _postsList.length - 1 - index : index];
              if ((tmp["text"] as String).startsWith("[洞主]"))
                tmp["color"] = _postsList[0]["color"];
              return PostWidget(
                tmp,
                isDetailMode: true,
                replyCallback: (dynamic info) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            contentPadding: EdgeInsets.all(0.0),
                            content: ReplyWidget(
                              refresh,
                              info,
                            ));
                      });
                },
              );
            }),
      ),
    );
  }

  setAttention() async {
    if (_isSettingAttention) return;
    setState(() {
      _isSettingAttention = true;
    });
    HoleType type = info['holeType'];
    final String token = await type.getToken();
    Map<String, String> body = {
      "switch": _alreadyAttention ? '0' : '1',
      "pid": info["pid"].toString(),
      "user_token": token
    };
    http
        .post(
            type.getApiBase() +
                "/api.php?action=attention&PKUHelperAPI=3.0" +
                tokenParams(token),
//            headers: {
//              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
//            },
            body: body)
        .then((resp) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0) throw Exception(j["msg"]);
      showInfoToast(_alreadyAttention ? "取消关注成功" : "关注成功");
      setState(() {
        _alreadyAttention = !_alreadyAttention;
        _isSettingAttention = false;
      });
    }).catchError((e) {
      showErrorToast(e.toString());
      setState(() {
        _isSettingAttention = false;
      });
    });
  }
}

Widget buildScrollBar(
  Color backgroundColor2,
  Animation<double> thumbAnimation,
  Animation<double> labelAnimation,
  double height, {
  Text labelText,
  BoxConstraints labelConstraints,
}) {
  final scrollThumb = CustomPaint(
//    key: scrollThumbKey,
//    foregroundPainter: ArrowCustomPainter(Colors.white),
    foregroundPainter: ArrowCustomPainter(brighten(holeSecondaryColor, 20)),
    child: Material(
      elevation: 4.0,
      child: Container(
        constraints: BoxConstraints.tight(Size(height * 0.6, height)),
      ),
//      color: darken(secondaryColor, 20),
      color: holeBackgroundColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(height),
        bottomLeft: Radius.circular(height),
        topRight: Radius.circular(4.0),
        bottomRight: Radius.circular(4.0),
      ),
    ),
  );

  return DraggableScrollbar.buildScrollThumbAndLabel(
    scrollThumb: scrollThumb,
    backgroundColor: holeBackgroundColor,
    thumbAnimation: thumbAnimation,
    labelAnimation: labelAnimation,
    labelText: labelText,
    labelConstraints: labelConstraints,
    alwaysVisibleScrollThumb: false,
  );
}
