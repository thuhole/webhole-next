import 'package:flutter/material.dart';
import 'package:webhole/config.dart';
import 'package:webhole/widgets/postWidget.dart';

import '../network.dart';

enum FlowType { attention, posts }

class FlowChunk extends StatefulWidget {
  final ScrollController _scrollBottomBarController;
  final FlowType _flowType;

  FlowChunk(Key key, this._scrollBottomBarController, this._flowType)
      : super(key: key);

  @override
  FlowChunkState createState() => FlowChunkState.defaultFetcher(
      this._scrollBottomBarController, this._flowType);
}

class FlowChunkState extends State<FlowChunk> {
  dynamic _postsList = [];

  ScrollController _scrollBottomBarController;

  MergedHoleFetcher _itemFetcher;
  final FlowType _flowType;

  bool _isLoading = true;
  bool _hasMore = true;
  bool _onError = false;
  bool _disposed = false;
  bool _showAppBar = true;
  String errorMsg;

  FlowChunkState(
      this._scrollBottomBarController, this._flowType, this._itemFetcher);

  FlowChunkState.defaultFetcher(_scrollBottomBarController, _flowType)
      : this(
            _scrollBottomBarController,
            _flowType,
            _flowType == FlowType.posts
                ? MergedHoleFetcher(
                    [PostsFetcher(HoleType.t), PostsFetcher(HoleType.p)])
                : MergedHoleFetcher([
                    AttentionFetcher(HoleType.t),
                    AttentionFetcher(HoleType.p)
                  ]));

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _itemFetcher.reset();
    _loadMore();
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _onError = false;
      _showAppBar = true;
      _postsList = [];
      _itemFetcher.reset();
      _loadMore();
    });
  }

  Future<void> setShowAppbar(bool show) async {
    setState(() {
      _showAppBar = show;
    });
  }

  void _loadMore() {
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
            )
          : null,
      floatingActionButton: _flowType == FlowType.posts
          ? FloatingActionButton(
              onPressed: () {
                // Add your onPressed code here!
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
//                controller: _searchQuery,
        style: new TextStyle(
          color: Colors.white,
        ),
        autofocus: false,
        decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            border: InputBorder.none,
            hintStyle: new TextStyle(color: Colors.white)),
      ),
    );
  }
}
