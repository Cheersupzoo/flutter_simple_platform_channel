import 'dart:async';

import 'package:flutter/material.dart';
import './platform_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textController;
  String _textRecieved;
  PlatformChannel _platformChannel;
  int _time;
  StreamSubscription _timerSubscription;

  @override
  void initState() {
    _textController = TextEditingController(text: '');
    _platformChannel = PlatformChannel();
    _time = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Text for send',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextFormField(
                controller: _textController,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Text received',
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '$_textRecieved',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              height: 8,
            ),
            RaisedButton(
                onPressed: () async {
                  _textRecieved = await _platformChannel
                      .getStringReturnFromPlatform(_textController.text);
                  setState(() {});
                },
                child: Text("Send Text")),
            Divider(height: 32, thickness: 4),
            Text("Timer"),
            Text(
              "$_time",
              style: Theme.of(context).textTheme.headline5,
            ),
            Row(children: <Widget>[
              RaisedButton(
                  onPressed: () async {
                    _timerSubscription =
                        _platformChannel.getTimerStream.listen((int time) {
                      setState(() {
                        _time = time;
                      });
                    });
                  },
                  child: Text("Start")),
              RaisedButton(
                  onPressed: () async {
                    _timerSubscription.cancel();
                  },
                  child: Text("Stop")),
            ])
          ],
        ),
      ),
    );
  }
}