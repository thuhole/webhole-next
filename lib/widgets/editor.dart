import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:webhole/config.dart';

import '../utils.dart';
import 'postWidget.dart';

class EditorWidget extends StatefulWidget {
  final Function callback;

  EditorWidget(this.callback);

  @override
  _EditorWidgetState createState() => _EditorWidgetState(this.callback);
}

class _EditorWidgetState extends State<EditorWidget>
    with SingleTickerProviderStateMixin {
  final Function callback;

  _EditorWidgetState(this.callback);

  final _picker = ImagePicker();
  Uint8List _image;
  Map<String, dynamic> info = {};

  TextEditingController _textController = TextEditingController();
  TabController _tabController;
  bool compressed = false;

  bool _showDropdown = false;
  bool _isSending = false;
  String dropdownValue = 'T大树洞';

  void initDropdown() async {
    bool _hasPkuToken = isValidToken(await HoleType.p.getToken());
    bool _hasThuToken = isValidToken(await HoleType.t.getToken());
    if (_hasPkuToken && _hasThuToken) {
      setState(() {
        _showDropdown = true;
      });
    } else {
      dropdownValue = _hasPkuToken ? 'P大树洞' : 'T大树洞';
    }
  }

  Uint8List compressImage(Uint8List imageBytes) {
    im.Image image = im.decodeImage(imageBytes);
    int width = image.width;
    int height = image.width;
    compressed = false;

    print("1");
    print(height);
    print(width);

    if (width > MAX_IMG_DIAM) {
      height = (height * MAX_IMG_DIAM) ~/ width;
      width = MAX_IMG_DIAM;
      compressed = true;
    }

    print("2");
    print(height);
    print(width);
    if (height > MAX_IMG_DIAM) {
      width = (width * MAX_IMG_DIAM) ~/ height;
      height = MAX_IMG_DIAM;
      compressed = true;
    }

    print("3");
    print(height);
    print(width);
    if (height * width > MAX_IMG_PX) {
      double rate = sqrt((height * width) / MAX_IMG_PX);
      height ~/= rate;
      width ~/= rate;
      compressed = true;
    }

    print("4");
    print(height);
    print(width);
    if (compressed) image = im.copyResize(image, height: height, width: width);

    return im.encodeJpg(image);
  }

  void updatePreviewInfo() {
    info["pid"] = 0;
    info["timestamp"] =
        (new DateTime.now().toUtc().microsecondsSinceEpoch ~/ 1000000);
    info["reply"] = 0;
    info["likenum"] = 0;
    info["color"] = primaryColor;
    info["holeType"] = HoleType.p;
    info["text"] = _textController.text;
    info["rawImage"] = _image;
  }

  @override
  void initState() {
    super.initState();
    updatePreviewInfo();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        setState(() {
          updatePreviewInfo();
        });
      }
    });
    initDropdown();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text("发表树洞"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            tabs: <Widget>[
              Tab(
                child: Text(
                  '编辑',
                ),
              ),
              Tab(
                child: Text(
                  '预览',
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(fontSize: 16),
                        controller: _textController,
                        minLines: 5,
                        maxLines: max((constraints.maxHeight - 240) ~/ 16, 5),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '请遵守相关树洞管理规范，文明发言。',
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        RaisedButton(
                          onPressed: () async {
                            final pickedFile = await _picker.getImage(
                                source: ImageSource.gallery);
                            _image =
                                compressImage(await pickedFile.readAsBytes());
                            setState(() {});
                          },
                          color: secondaryColor,
                          child: Text(
                              _image == null
                                  ? '上传图片'
                                  : '图片(' +
//                                      (compressed ? '压缩至' : '') +
                                      filesize(_image.length, 1) +
                                      ')',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        Spacer(),
                        _showDropdown
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildDropDownButton(),
                              )
                            : Container(),
                        RaisedButton(
                          onPressed: send,
                          color: secondaryColor,
                          child: Text(_isSending ? '正在发送' : '发送',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
            ListView.builder(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(top: 16.0, bottom: 60.0),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return PostWidget(
                    this.info,
                    isDetailMode: true,
                  );
                }),
          ],
        ),
      ),
    );
  }

  static Color getDropDownColor(String str) {
    return str == 'T大树洞' ? thuPurple : pkuRed;
  }

  Widget _buildDropDownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      style: TextStyle(color: getDropDownColor(dropdownValue)),
      underline: Container(
        height: 2,
        color: brighten(getDropDownColor(dropdownValue), 40),
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['T大树洞', 'P大树洞']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: getDropDownColor(value)),
          ),
        );
      }).toList(),
    );
  }

  send() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });
    HoleType type = dropdownValue == 'T大树洞' ? HoleType.t : HoleType.p;
    final String token = await type.getToken();
    Map<String, String> body = {
      "text": _textController.text,
      "type": _image == null ? "text" : "image"
    };
    if (_image != null) body["data"] = base64.encode(_image);
    http
        .post(
            type.getApiBase() +
                "/api.php?action=dopost&PKUHelperAPI=3.0" +
                tokenParams(token),
//            headers: {
//              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
//            },
            body: body)
        .then((resp) {
      dynamic j = json.decode(resp.body);
      if (j["code"] != 0)
        throw Exception(j["msg"]);
      else {
        Navigator.pop(context);
        callback();
      }
    }).catchError((e) {
      showErrorToast(e.toString());
      setState(() {
        _isSending = false;
      });
    });
  }
}
