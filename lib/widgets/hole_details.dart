import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  bool _disposed = false;
  String errorMsg;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

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
    print("flow build");
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
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.report_problem),
              backgroundColor: Colors.red,
              label: '举报',
//              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => print('FIRST CHILD')),
          SpeedDialChild(
            child: Icon(Icons.sort),
            backgroundColor: secondaryColor,
            label: '逆序',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('SECOND CHILD'),
          ),
          SpeedDialChild(
            child: Icon(Icons.refresh),
            backgroundColor: secondaryColor,
            label: '刷新',
//            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('THIRD CHILD'),
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
                top: 16.0 + MediaQuery.of(context).padding.top, bottom: 16.0),
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
              return PostWidget(
                _comments[index - 1],
                clickable: false,
                type: "cid",
              );
            }),
      ),
    );
  }
}
