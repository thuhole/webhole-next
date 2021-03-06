import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../utils.dart';

class SettingsWidget extends StatefulWidget {
  final Function refreshHome;

  SettingsWidget(this.refreshHome);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState(this.refreshHome);
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final myController = TextEditingController();

//  bool _autoUpdate = true;
  bool _hasThuToken = false;
  bool _hasPkuToken = false;
  Function refreshHome;

  String version = "";

  _SettingsWidgetState(this.refreshHome);

  @override
  void initState() {
    super.initState();
    readPreferences().then((value) => {setState(() {})});
  }

  Future<void> readPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
//    _autoUpdate = prefs.getBool("autoUpdate");
//    if (_autoUpdate == null) _autoUpdate = true;
    _hasPkuToken = isValidToken(prefs.getString("pkuToken"));
    _hasThuToken = isValidToken(prefs.getString("thuToken"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: holeSecondaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("登录", style: TextStyle(fontSize: 18.0)),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("T大树洞 Token登录"),
              subtitle: Text(_hasThuToken ? "已登录" : "从其他设备导入登录状态"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showLoginDialog(context, () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    _hasThuToken = isValidToken(prefs.getString("thuToken"));
                  });
                }, HoleType.t);
              },
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("P大树洞 Token登录"),
              subtitle: Text(_hasPkuToken ? "已登录" : "从其他设备导入登录状态"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showLoginDialog(context, () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    _hasPkuToken = isValidToken(prefs.getString("pkuToken"));
                  });
                }, HoleType.p);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "个性化",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("主要颜色"),
              trailing: CircleAvatar(
                backgroundColor: holePrimaryColor,
              ),
              onTap: () {
                showColorPicker(context, holePrimaryColor, changePrimaryColor);
              },
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("次要颜色"),
              trailing: CircleAvatar(
                backgroundColor: holeSecondaryColor,
              ),
              onTap: () {
                showColorPicker(context, holeSecondaryColor, changeSecondaryColor);
              },
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("背景颜色"),
              trailing: CircleAvatar(
                backgroundColor: holeBackgroundColor,
              ),
              onTap: () {
                showColorPicker(
                    context, holeBackgroundColor, changeBackgroundColor);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "通用",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
//          Card(
//            elevation: 4,
//            child: ListTile(
//              title: Text("自动检查更新"),
//              subtitle: Text("To be implemented"),
//              trailing: Switch(
//                value: _autoUpdate,
//                onChanged: (bool value) async {
//                  SharedPreferences prefs =
//                      await SharedPreferences.getInstance();
//                  prefs.setBool("autoUpdate", value);
//                  setState(() {
//                    _autoUpdate = value;
//                    print("TODO");
//                  });
//                },
//              ),
//            ),
//          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("GitHub主页"),
              subtitle: Text("当前树洞版本：" + version),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                await launch(GitHubPage);
              },
            ),
          ),
        ],
      ),
    );
  }

  void changePrimaryColor(Color color) async {
    setState(() {
      holePrimaryColor = color;
    });
    refreshHome();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
  }

  void changeSecondaryColor(Color color) async {
    setState(() {
      holeSecondaryColor = color;
    });
    refreshHome();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondaryColor', color.value);
  }

  void changeBackgroundColor(Color color) async {
    setState(() {
      holeBackgroundColor = color;
    });
    refreshHome();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('backgroundColor', color.value);
  }

  showColorPicker(
      BuildContext context, Color pickerColor, Function changeColor) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          // Use Material color picker:
          //
          child: MaterialPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
//             showLabel: true, // only on portrait mode
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
//              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class TokenForm extends StatefulWidget {
  final void Function(String) callback;

  TokenForm({Key key, this.callback}) : super(key: key);

  @override
  _TokenFormState createState() => _TokenFormState(callback);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _TokenFormState extends State<TokenForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final textController = TextEditingController();
  final void Function(String) callback;

  _TokenFormState(this.callback);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                  decoration: InputDecoration(
                      labelText: 'Token',
                      hintText: '从其他设备中复制过来的Token',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0)))),
                  controller: textController,
                  autofocus: true),
              Center(
                child: SizedBox(
                  width: 320.0,
                  child: RaisedButton(
                    onPressed: () {
//                      _saveToken(type, textController.text);
                      Navigator.pop(context);
                      callback(textController.text);
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: holeSecondaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void showLoginDialog(BuildContext context, Function callback, HoleType type) {
  showDialog(
      context: context,
      builder: (w) {
        return TokenForm(
          callback: (token) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                type == HoleType.t ? 'thuToken' : 'pkuToken', token);
            showInfoToast("已保存token:" + token);
            if (callback != null) callback();
          },
        );
      });
}
