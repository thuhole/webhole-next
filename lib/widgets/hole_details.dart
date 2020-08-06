import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:webhole/network.dart';
import 'package:webhole/utils.dart';

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
  OneTypeHoleFetcher _itemFetcher;

  HoleDetailsState(this.info);

  bool _isLoading = false;
  bool _hasMore = true;
  bool _onError = false;
  bool _disposed = false;
  bool _reversed = false;
  String errorMsg;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
//    _itemFetcher = CommentFetcher(this.info["holeType"], this.info["pid"]);
    _itemFetcher = TwoPageFetcher(
        this.info["holeType"],
        SavedHoleFetcher(this.info["holeType"], [this.info]),
        CommentFetcher(this.info["holeType"], this.info["pid"]));
    _loadMore();
  }

  Future<void> refresh() async {
    setState(() {
      _onError = false;
      _hasMore = true;
      _postsList = [];
      _loadMore();
    });
  }

  void _loadMore() {
    if (_isLoading) return;
    _isLoading = true;
    _itemFetcher.fetch().then((List<dynamic> fetchedList) {
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
      if (!_disposed) {
        setState(() {
          _isLoading = false;
          _onError = true;
          errorMsg = e.toString();
          print(e);
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
        overlayColor: Colors.white,
        overlayOpacity: 0.5,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: const Icon(Icons.report_problem),
              backgroundColor: Colors.red,
              label: '举报',
//              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => showErrorToast("Not implemented")),
          SpeedDialChild(
            child: const Icon(Icons.sort),
            backgroundColor: secondaryColor,
            label: _reversed ? '顺序' : '逆序',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => {
              setState(() {
                _reversed = !_reversed;
              })
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.content_copy),
            backgroundColor: secondaryColor,
            label: '复制全文',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => showErrorToast("Not implemented"),
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: secondaryColor,
            label: '刷新',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              _itemFetcher = TwoPageFetcher(
                  this.info["holeType"],
                  OneHoleFetcher(
                      this.info["holeType"], this.info["pid"].toString()),
                  CommentFetcher(this.info["holeType"], this.info["pid"]));
              refresh();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(color: backgroundColor),
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
                    Navigator.of(context)
                        .popUntil((route) => route.settings.name == '/');
                  },
                  icon: const BackButtonIcon(),
                  label: Text(
                    MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  backgroundColor: secondaryColor,
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
      child: DraggableScrollbar.rrect(
        controller: _rrectController,
        backgroundColor: Colors.black,
        child: ListView.builder(
            controller: _rrectController,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(
                top: 16.0 + MediaQuery.of(context).padding.top, bottom: 60.0),
            itemCount: _hasMore ? _postsList.length + 1 : _postsList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= _postsList.length - 10 &&
                  !_onError &&
                  !_isLoading &&
                  _hasMore) {
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
              return PostWidget(
                _postsList[_reversed ? _postsList.length - 1 - index : index],
                isDetailMode: true,
              );
            }),
      ),
    );
  }
}
