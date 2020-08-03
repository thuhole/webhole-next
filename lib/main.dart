// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'flow.dart';
import 'settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  ScrollController _scrollController;
  double _containerMaxHeight = 56, _offset, _delta = 0, _oldOffset = 0;

  int _selectedIndex = 0;
  static List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    this._c.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  PageController _c;

  @override
  void initState() {
    _c = new PageController(
      initialPage: _selectedIndex,
    );
    super.initState();
    _offset = 0;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          double offset = _scrollController.offset;
          _delta += (offset - _oldOffset);
          if (_delta > _containerMaxHeight)
            _delta = _containerMaxHeight;
          else if (_delta < 0) _delta = 0;
          _oldOffset = offset;
          _offset = -_delta;
        });
      });
    _widgetOptions = <Widget>[
      FlowChunk(this._scrollController),
      Scaffold(
        body: Center(
          child: Text(
            'Page not implemented',
          ),
        ),
      ),
      SettingsWidget(),
    ];
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView(
                controller: _c,
                onPageChanged: (newPage) {
                  setState(() {
                    this._selectedIndex = newPage;
                  });
                },
                children: _widgetOptions),
            Positioned(
                bottom: _offset,
                width: constraints.maxWidth,
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
                  selectedItemColor: Colors.orange,
                  onTap: _onItemTapped,
                )),
          ],
        );
      },
    );
  }
}
