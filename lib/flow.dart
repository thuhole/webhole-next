import 'package:flutter/material.dart';
import 'package:webhole/config.dart';

import 'network.dart';

class FlowChunk extends StatefulWidget {
  final ScrollController _scrollBottomBarController;

  FlowChunk(this._scrollBottomBarController);

  @override
  _FlowChunkState createState() =>
      _FlowChunkState(this._scrollBottomBarController);
}

class _FlowChunkState extends State<FlowChunk> {
  final _postsList = [];

  ScrollController _scrollBottomBarController;
//  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _itemFetcher = PostFetcher();

  bool _isLoading = true;
  bool _hasMore = true;
  bool _onError = false;
  String errorMsg;
  int _currentPage = 1;

  _FlowChunkState(this._scrollBottomBarController);

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _loadMore(_currentPage);
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
    return Scaffold(
//      appBar: AppBar(
//        title: Text('Startup Name Generator'),
//      ),

//        body: _buildSuggestions()
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets\\a.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildPosts()),
    );
  }

  Widget _buildRow(int index) {
    String pidText = "#" + _postsList[index]["pid"].toString();
//    Color color = Colors.amberAccent;
    Color color = Color.fromRGBO(141, 163, 210, 1);
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0)),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            print('Card tapped.');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: color,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 8.0),
                      child: Text(pidText),
                    ),
                    Text("大约？分钟之前"),
                    Spacer(),
                    Icon(Icons.comment),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(_postsList[index]["reply"].toString()),
                    ),
                    Icon(Icons.star),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(_postsList[index]["likenum"].toString()),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 0,
              ),
              _postsList[index]["text"].toString().length > 0 ? Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Text(_postsList[index]["text"].toString()),
                ),
              ) : Container(),
              _postsList[index]["type"] == "image" ? Container(
                child: Image.network(
                  THUHOLE_IMAGE_BASE + _postsList[index]["url"].toString(),
                ),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosts() {
    return ListView.builder(
        physics: ClampingScrollPhysics(),
        controller: _scrollBottomBarController,
        padding: EdgeInsets.all(16.0),
        itemCount: _hasMore ? _postsList.length + 1 : _postsList.length,
        itemBuilder: (BuildContext context, int index) {
          // Uncomment the following line to see in real time how ListView.builder works
          // print('ListView.builder is building index $index');
          if (index >= _postsList.length) {
            // Don't trigger if one async loading is already under way
            if (_onError) {
              return Center(
                child: Text("Error: " + errorMsg),
              );
            }
            if (!_isLoading) {
              _loadMore(_currentPage);
            }
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 24,
                width: 24,
              ),
            );
          }
          return _buildRow(index);
        });
  }
}
