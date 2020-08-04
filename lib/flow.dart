import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:webhole/config.dart';
import 'package:webhole/utils.dart';

import 'network.dart';

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

  Widget _buildRow(int index) {
    String pidText = "#" + _postsList[index]["pid"].toString();
//    Color color = Color.fromRGBO(141, 163, 210, 1);
    return Center(
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
//          borderRadius: BorderRadius.only(
//              topRight: Radius.circular(15.0),
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
        ),
        child: InkWell(
          splashColor: secondaryColor,
          onTap: () {
            print('Card tapped.');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: new BoxDecoration(color: primaryColor),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 8.0),
                      child: Text(pidText +
                          "  " +
                          getDateDiff((new DateTime.now()
                                      .toUtc()
                                      .microsecondsSinceEpoch ~/
                                  1000000) -
                              _postsList[index]["timestamp"])),
                    ),
                    Spacer(),
                    _postsList[index]["reply"] > 0 ? Icon(
                      Icons.comment,
                      size: 20,
                    ) : Container(),
                    _postsList[index]["reply"] > 0 ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(_postsList[index]["reply"].toString()),
                    ) : Container(),
                    _postsList[index]["likenum"] > 0 ? Icon(
                      Icons.star,
                      size: 20,
                    ) : Container(),
                    _postsList[index]["likenum"] > 0 ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(_postsList[index]["likenum"].toString()),
                    ) : Container(),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 0,
              ),
              _postsList[index]["text"].toString().length > 0
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 16.0),
                        child: Text(_postsList[index]["text"].toString()),
                      ),
                    )
                  : Container(),
              _postsList[index]["type"] == "image"
                  ? Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        Center(
                          child: FadeInImage.memoryNetwork(
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: kTransparentImage,
                            image: THUHOLE_IMAGE_BASE +
                                _postsList[index]["url"].toString(),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
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
            return _buildRow(index);
          }),
    );
  }
}
