import 'package:flutter/material.dart';
import 'package:webhole/config.dart';
import 'package:webhole/utils.dart';
import 'package:webhole/widgets/postWidget.dart';

import '../network.dart';
import 'editor.dart';
import 'settings.dart';

enum FlowType { attention, posts }

class FlowChunk extends StatefulWidget {
  final ScrollController _scrollBottomBarController;
  final FlowType _flowType;

  FlowChunk(Key key, this._scrollBottomBarController, this._flowType)
      : super(key: key);

  @override
  FlowChunkState createState() =>
      FlowChunkState(this._scrollBottomBarController, this._flowType);
}

class FlowChunkState extends State<FlowChunk> {
  dynamic _postsList = [];

  ScrollController _scrollBottomBarController;

  HoleFetcher _itemFetcher;
  final FlowType _flowType;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _onError = false;
  bool _disposed = false;
  bool _showAppBar = true;
  String errorMsg;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;

  FlowChunkState(this._scrollBottomBarController, this._flowType);

  static MergedHoleFetcher getMergedFetcher(FlowType _flowType) {
    return _flowType == FlowType.posts
        ? MergedHoleFetcher(
            [PostsFetcher(HoleType.t), PostsFetcher(HoleType.p)])
        : MergedHoleFetcher(
            [AttentionFetcher(HoleType.t), AttentionFetcher(HoleType.p)]);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    _itemFetcher = getMergedFetcher(_flowType);
    super.initState();
    _isLoading = false;
    _hasMore = true;
    _loadMore();
  }

  Future<void> refresh() async {
    setState(() {
      _itemFetcher = getMergedFetcher(_flowType);
      _searchQueryController.clear();
      _isSearching = false;
      _hasMore = true;
      _onError = false;
      _showAppBar = true;
      _isLoading = false;
      _postsList = [];
      _loadMore();
    });
  }

  Future<void> setShowAppbar(bool show) async {
    setState(() {
      _showAppBar = show;
    });
  }

  void _loadMore() {
    if (_isLoading) return;
    _isLoading = true;
    String oldSearchParams = _searchQueryController.text;
    _itemFetcher.fetch().then((List<dynamic> fetchedList) {
      if (oldSearchParams != _searchQueryController.text) return;
// Do not update if the search keywords have changes.

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
    print("flow build, item count=" +
        (_hasMore ? _postsList.length + 1 : _postsList.length).toString());
    return Scaffold(
//      appBar: AppBar(
//        title: Text('树洞'),
//        toolbarHeight: 0,
//        backgroundColor: secondaryColor,
//      ),
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: primaryColor,
              title: buildSearch(),
              actions: _isSearching
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          refresh();
                        },
                      ),
                    ]
                  : null,
            )
          : null,
      floatingActionButton: _flowType == FlowType.posts
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return EditorWidget(refresh);
                }));
              },
              child: Icon(Icons.add),
              backgroundColor: secondaryColor,
            )
          : null,
      body: Container(
//          decoration: BoxDecoration(
//            image: DecorationImage(
//              image: AssetImage("assets/a.jpg"),
//              fit: BoxFit.cover,
//            ),
//          ),
          decoration: new BoxDecoration(color: backgroundColor),
          child: _buildPosts()),
    );
  }

  Widget _buildPosts() {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
          physics: ClampingScrollPhysics(),
          controller: _scrollBottomBarController,
          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
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
                if (errorMsg == "Exception: 尚未登录") {
                  return Center(
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 10,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            showLoginDialog(context, refresh, HoleType.t);
                          },
                          color: secondaryColor,
                          child: Text('T大树洞登录',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        RaisedButton(
                          onPressed: () {
                            showLoginDialog(context, refresh, HoleType.p);
                          },
                          color: secondaryColor,
                          child: Text('P大树洞登录',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
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
            return PostWidget(_postsList[index]);
          }),
    );
  }

  Widget buildSearch() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 16.0 + MediaQuery.of(context).padding.top,
          horizontal: 16.0),
      child: TextField(
        controller: _searchQueryController,
        style: new TextStyle(
          color: Colors.white,
        ),
        autofocus: false,
        onChanged: (query) => {
          setState(() {
            _isSearching = _searchQueryController.text.isNotEmpty;
          })
        },
        onSubmitted: (str) async {
          if (str.length == 0) {
            refresh();
          } else if (str.startsWith("#")) {
            String pidString = str.substring(1);
            _itemFetcher = MergedHoleFetcher([
              OneHoleFetcher(HoleType.t, pidString),
              OneHoleFetcher(HoleType.p, pidString)
            ]);
            _isLoading = false;
            _hasMore = true;
            _onError = false;
            _postsList = [];
            _loadMore();
          } else {
            bool isHotspot =
                (str == '热榜' && isValidToken(await HoleType.t.getToken()));
            setState(() {
              _itemFetcher = isHotspot
                  ? SearchPostsFetcher(HoleType.t, str)
                  : MergedHoleFetcher([
                      SearchPostsFetcher(HoleType.t, str),
                      SearchPostsFetcher(HoleType.p, str)
                    ]);
              _isLoading = false;
              _hasMore = true;
              _onError = false;
              _postsList = [];
              _loadMore();
            });
          }
        },
        decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            border: InputBorder.none,
            hintStyle: new TextStyle(color: Colors.white)),
      ),
    );
  }
}
