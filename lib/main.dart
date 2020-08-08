import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:upgrader/upgrader.dart';
import 'package:webhole/config.dart';
import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

import 'widgets/flow.dart';
import 'widgets/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UmengAnalyticsPlugin.init(
//      logEnabled: true,
      androidKey: '5f2d2998d30932215475ff4c',
      iosKey: '5f2d2bdbb4b08b653e923f5b',
    );
    final appcastURL =
        'https://gitee.com/thuhole/app-release/raw/master/appcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
//    checkUpdate();

    return MaterialApp(
      theme: ThemeData(
//        //main color
//          primaryColor: const Color(0xffFFC600),
        //main font
        fontFamily: 'Roboto-Medium',
//        brightness: Brightness.dark,
//          //swatch stretching
//          primarySwatch: goldenThemeColor,
//          visualDensity: VisualDensity.adaptivePlatformDensity,

//          splashColor:  const Color(0xffFFC600),

        //color for scrollbar
//          highlightColor: Colors.black
      ),
      home: UpgradeAlert(
        appcastConfig: cfg,
        showIgnore: false,
        debugLogging: !kReleaseMode,
//        debugAlwaysUpgrade: true,
        daysToAlertAgain: 1,
        canDismissDialog: true,
        child: HomeWidget(),
        messages: ChineseMessages(),
      ),
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
    _selectedIndex = index;
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
                    selectedItemColor: holePrimaryColor,
                    onTap: _onItemTapped,
                  ),
                )),
          ],
        );
      },
    );
  }
}

class ChineseMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'zh') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return '{{appName}}有了新版本! 新版本是{{currentAppStoreVersion}}，你当前的版本是{{currentInstalledVersion}}。';
        case UpgraderMessage.buttonTitleIgnore:
          return '忽略';
        case UpgraderMessage.buttonTitleLater:
          return '稍后更新';
        case UpgraderMessage.buttonTitleUpdate:
          return '立即更新';
        case UpgraderMessage.prompt:
          return '是否现在更新？';
        case UpgraderMessage.title:
          return '更新应用？';
      }
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}
