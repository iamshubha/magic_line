import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:http/http.dart';

import 'TextContaint.dart';

class BucketGetPage extends StatefulWidget {
  @override
  _BucketGetPageState createState() => _BucketGetPageState();
}

class _BucketGetPageState extends State<BucketGetPage> {
  String bucketName = "tech";
  var bucketData;
  List data;

  getBucketData() async {
    try {
      var response = await http
          .get(Uri.encodeFull('http://42a57e78e204.ngrok.io/note/$bucketName'));
      setState(() {
        var convertDataToJson = json.decode(response.body);
        data = convertDataToJson;
        var responseData = json.decode(response.body);
        bucketData = responseData;
        print(responseData.length);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getBucketData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => MyApp()));
          },
          child: Icon(Icons.text_fields),
        ),
        title: Text('Buckets Data'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return;
        },
        itemCount: 2,
      ),
    );
  }
}
