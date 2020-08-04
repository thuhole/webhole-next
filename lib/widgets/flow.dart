import 'package:flutter/material.dart';
import 'package:webhole/config.dart';
import 'package:webhole/widgets/postWidget.dart';

import '../network.dart';

class FlowChunk extends StatefulWidget {
  final ScrollController _scrollBottomBarController;
  final HoleFetcher fetcher;

  FlowChunk(Key key, this._scrollBottomBarController, this.fetcher)
      : super(key: key);

  @override
  FlowChunkState createState() =>
      FlowChunkState(this._scrollBottomBarController, this.fetcher);
}

class FlowChunkState extends State<FlowChunk> {
  dynamic _postsList = [];

  ScrollController _scrollBottomBarController;

//  final _biggerFont = const TextStyle(fontSize: 18.0);
  final HoleFetcher _itemFetcher;

  bool _isLoading = true;
  bool _hasMore = true;
  bool _onError = false;
  String errorMsg;
  int _currentPage = 1;

  FlowChunkState(this._scrollBottomBarController, this._itemFetcher);

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _loadMore(_currentPage);
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _onError = false;
      _currentPage = 1;
      _postsList = [];
      _loadMore(_currentPage);
    });
  }

  void _loadMore(int page) {
    _isLoading = true;
    _itemFetcher.fetch(page).then((List<dynamic> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _postsList.addAll(fetchedList);
          _currentPage = _currentPage + 1;
        });
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _onError = true;
        errorMsg = e.toString();
        print(e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("flow build");
    return Scaffold(
//      appBar: AppBar(
//        title: Text('树洞'),
//        toolbarHeight: 0,
//        backgroundColor: secondaryColor,
//      ),

//        body: _buildSuggestions()
      floatingActionButton: Align(
        child: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(Icons.add),
          backgroundColor: secondaryColor,
        ),
        alignment: Alignment(1, 0.8),
      ),
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
          padding: EdgeInsets.all(16.0),
          itemCount: _hasMore ? _postsList.length + 1 : _postsList.length,
          itemBuilder: (BuildContext context, int index) {
            if (index >= _postsList.length - 10 && !_onError && !_isLoading) {
              // preload
              _loadMore(_currentPage);
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
}
