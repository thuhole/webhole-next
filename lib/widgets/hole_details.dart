import 'package:flutter/material.dart';
import 'package:webhole/network.dart';

import '../config.dart';
import 'postWidget.dart';

class HoleDetails extends StatefulWidget {
  final dynamic info;

  HoleDetails(this.info);

  @override
  HoleDetailsState createState() =>
      HoleDetailsState(this.info, CommentFetcher());
}

class HoleDetailsState extends State<HoleDetails> {
  dynamic info;
  List<dynamic> _comments = [];
  final CommentFetcher _itemFetcher;

  HoleDetailsState(this.info, this._itemFetcher);

  bool _isLoading = true;
  bool _onError = false;
  String errorMsg;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    load();
  }

  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
      _onError = false;
      load();
    });
  }

  void load() {
    _isLoading = true;
    _itemFetcher.fetch(this.info["pid"]).then((List<dynamic> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _comments = fetchedList;
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
      appBar: AppBar(
        title: Text('#' + info["pid"].toString()),
//        toolbarHeight: 0,
        backgroundColor: primaryColor,
      ),
      body: Container(
          decoration: new BoxDecoration(color: backgroundColor),
          child: _buildPosts()),
    );
  }

  Widget _buildPosts() {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          itemCount: _isLoading ? _comments.length + 2 : _comments.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return PostWidget(info, clickable: false);
            }
            if (index >= _comments.length + 1) {
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
            return PostWidget(_comments[index - 1], clickable: false);
          }),
    );
  }
}
