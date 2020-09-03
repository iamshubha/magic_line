import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:magic_line/main.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class TextContaintPage extends StatefulWidget {
  @override
  _TextContaintPageState createState() => _TextContaintPageState();
}

class _TextContaintPageState extends State<TextContaintPage> {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  String url = 'http://cf76c49cea3d.ngrok.io/note';
 
  _makePostRequest() async {
    print(json);
    Response response = await http.post(url,
        body: jsonEncode(<String, String>{
          "note": "$_text",
          "date": "$_date",
          "bucket": "life"
        }));

    int statusCode = response.statusCode;
    String body = response.body;
    print(body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: 'Success',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue[300],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Somthing Wrong',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue[300],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String _text;
  DateTime _date;
  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ExamplePage()));
                },
                child: Icon(Icons.text_fields),
              ),
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: Column(children: <Widget>[
                Text("Shared files:", style: textStyleBold),
                Text(_sharedFiles?.map((f) => f.path)?.join(",") ?? ""),
                SizedBox(height: 100),
                Text("Shared urls/text:", style: textStyleBold),
                Text(_sharedText ?? ""),
                Form(
                  key: _loginFormKey,
                  child: TextFormField(
                    onSaved: (val) => _text = val,
                    initialValue: _sharedText,
                  ),
                ),
                ListTile(
                  title: Text("${_date.toString()}"),
                  leading: InkWell(
                    child: Icon(Icons.date_range),
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate:
                                  _date == null ? DateTime.now() : _date,
                              firstDate: DateTime(2010),
                              lastDate: DateTime.now())
                          .then((date) {
                        setState(() {
                          _date = date;
                        });
                      });
                    },
                  ),
                ),
                InkWell(
                    onTap: () {
                      _makePostRequest();
                    }, //,
                    child: Container(
                      child: Text("send"),
                    )),
                Container(
                  width: 200.0,
                  margin: EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                      child: Text(
                        "NEXT",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        final loginForm = _loginFormKey.currentState;
                        if (loginForm.validate()) {
                          loginForm.save();
                          _makePostRequest();
                        } else {
                          print("error");
                        }
                      }),
                ),
              ]),
            )));
  }

  final _loginFormKey = new GlobalKey<FormState>();
}
