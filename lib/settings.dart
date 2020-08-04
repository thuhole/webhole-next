import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webhole/config.dart';

class SettingsWidget extends StatefulWidget {
  final Function refreshHome;

  SettingsWidget(this.refreshHome);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState(this.refreshHome);
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final myController = TextEditingController();
  Function refreshHome;

  _SettingsWidgetState(this.refreshHome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: secondaryColor,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("登录"),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("Token登录"),
              subtitle: Text("从其他设备导入登录状态"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showDialog(context: context, builder: inputTokenDialog);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("个性化"),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("主要颜色"),
              trailing: CircleAvatar(
                backgroundColor: primaryColor,
              ),
              onTap: () {
                showColorPicker(context, primaryColor, changePrimaryColor);
              },
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("次要颜色"),
              trailing: CircleAvatar(
                backgroundColor: secondaryColor,
              ),
              onTap: () {
                showColorPicker(context, secondaryColor, changeSecondaryColor);
              },
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              title: Text("北京颜色"),
              trailing: CircleAvatar(
                backgroundColor: backgroundColor,
              ),
              onTap: () {
                showColorPicker(
                    context, backgroundColor, changeBackgroundColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  void changePrimaryColor(Color color) async {
    setState(() {
      primaryColor = color;
    });
    refreshHome();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
  }

  void changeSecondaryColor(Color color) async {
    setState(() {
      secondaryColor = color;
    });
    refreshHome();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondaryColor', color.value);
  }

  void changeBackgroundColor(Color color) async {
    setState(() {
      backgroundColor = color;
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
//          child: ColorPicker(
//            pickerColor: pickerColor,
//            onColorChanged: changeColor,
//            showLabel: true,
//            pickerAreaHeightPercent: 0.8,
//          ),
          // Use Material color picker:
          //
          child: MaterialPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
//             showLabel: true, // only on portrait mode
          ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
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

Widget inputTokenDialog(BuildContext context) {
  return TokenForm();
}

class TokenForm extends StatefulWidget {
  @override
  _TokenFormState createState() => _TokenFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _TokenFormState extends State<TokenForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final textController = TextEditingController();

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
                  decoration: InputDecoration(hintText: 'Token'),
                  controller: textController,
                  autofocus: true),
              Center(
                child: SizedBox(
                  width: 320.0,
                  child: RaisedButton(
                    onPressed: () {
                      _saveToken(textController.text);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: primaryColor,
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

_saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('thuToken', token);
}
