import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatelessWidget {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
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
          )
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
                    color: Colors.orange,
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
  await prefs.setString('token', token);
}
