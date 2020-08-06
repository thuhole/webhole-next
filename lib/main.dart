import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webhole/config.dart';

import 'widgets/flow.dart';
import 'widgets/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
//        //main color
//          primaryColor: const Color(0xffFFC600),
        //main font
        fontFamily: 'Roboto-Medium',
//          //swatch stretching
//          primarySwatch: goldenThemeColor,
//          visualDensity: VisualDensity.adaptivePlatformDensity,

//          splashColor:  const Color(0xffFFC600),

        //color for scrollbar
//          highlightColor: Colors.black
      ),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  ScrollController _timelineScrollController;
  ScrollController _attentionScrollController;
  double _containerMaxHeight = 56,
      _offset,
      _oldDelta = 0,
      _delta = 0,
      _oldOffset = 0;

  int _selectedIndex = 0;
  final GlobalKey<FlowChunkState> _keyPosts = GlobalKey();
  final GlobalKey<FlowChunkState> _keyAttention = GlobalKey();
  FlowChunk postsWidget;
  FlowChunk attentionWidget;
  SettingsWidget settingsWidget;

  void refresh() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      this._c.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    } else {
      if (index == 0) {
        _keyPosts.currentState.refresh();
      } else if (index == 1) {
        _keyAttention.currentState.refresh();
      }
    }
  }

  PageController _c;

  @override
  void initState() {
    initColor();
    _c = new PageController(
      initialPage: _selectedIndex,
    );
    super.initState();
    _offset = 0;
    _timelineScrollController = ScrollController()
      ..addListener(() {
        double offset = _timelineScrollController.offset;
        _delta += (offset - _oldOffset);
        if (_delta > _containerMaxHeight)
          _delta = _containerMaxHeight;
        else if (_delta < 0) _delta = 0;
        _oldOffset = offset;
        if (_delta != _oldDelta) {
          setState(() {
            _offset = -_delta;
          });
          if (_delta == 0 || _delta == _containerMaxHeight)
            _keyPosts.currentState.setShowAppbar(_delta == 0);
          if (_delta == _containerMaxHeight) FocusScope.of(context).unfocus();
        }
        _oldDelta = _delta;
      });
    _attentionScrollController = ScrollController()
      ..addListener(() {
        double offset = _attentionScrollController.offset;
        _delta += (offset - _oldOffset);
        if (_delta > _containerMaxHeight)
          _delta = _containerMaxHeight;
        else if (_delta < 0) _delta = 0;
        _oldOffset = offset;
        if (_delta != _oldDelta) {
          setState(() {
            _offset = -_delta;
          });
          if (_delta == 0 || _delta == _containerMaxHeight)
            _keyAttention.currentState.setShowAppbar(_delta == 0);
          if (_delta == _containerMaxHeight) FocusScope.of(context).unfocus();
        }
        _oldDelta = _delta;
      });
    postsWidget =
        FlowChunk(_keyPosts, this._timelineScrollController, FlowType.posts);
    attentionWidget = FlowChunk(
        _keyAttention, this._attentionScrollController, FlowType.attention);
    settingsWidget = SettingsWidget(refresh);
  }

  @override
  void dispose() {
    _timelineScrollController.removeListener(() {});
    _attentionScrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom == 0
                      ? _containerMaxHeight + this._offset
                      : 0),
              child: PageView(
                  controller: _c,
                  onPageChanged: (newPage) {
                    setState(() {
                      this._selectedIndex = newPage;
                      this._offset = 0;
                    });
                  },
                  children: [postsWidget, attentionWidget, settingsWidget]),
            ),
            Positioned(
                bottom: _offset,
                width: constraints.maxWidth,
                child: Container(
                  width: double.infinity,
                  height: _containerMaxHeight,
                  child: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.sync),
                        title: Text('时间线'),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.bookmark_border),
                        title: Text('关注'),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        title: Text('设置'),
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: primaryColor,
                    onTap: _onItemTapped,
                  ),
                )),
          ],
        );
      },
    );
  }
}
