import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:list_ext/list_ext.dart';

import 'package:test_mintrocket/constants.dart';
import 'package:test_mintrocket/models/FileElement.dart';
import 'package:test_mintrocket/screens/files_list/files_list.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String statusFiles = "";
  FlutterLocalNotificationsPlugin flnp;
  var _r = Random();
  Queue<int> waitFilesId;

  bool get _isDisableSaveBut => 
    fileElements.isEmpty || fileElements.any((x) => x.status == FileStatuses.loading);
  
  bool get _isDisableResetBut =>
    fileElements.isEmpty;

  @override
  void initState() {
    super.initState();
    _setStringStatus();
    flnp = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
    
    flnp.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
        centerTitle: true
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                ListTile(
                  title: Text('Файлы'),
                  subtitle: Text(statusFiles),
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    size: 48,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FilesList()
                      )
                    ).then((value) => 
                      _setStringStatus()
                    );
                  },
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Сбросить',
                    style: TextStyle(
                      color: _isDisableResetBut ? Colors.grey : Colors.black
                    )
                  ),
                  onPressed: _isDisableResetBut ? null : _resetFilesHandle
                ),
                Spacer(),
                FlatButton(

                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: _isDisableSaveBut ? Colors.grey : Colors.black
                    )
                  ),
                  onPressed: _isDisableSaveBut ? null : _saveFilesHandle
                )
              ],
            )
          )
        ],
      )
    );
  }

  void _resetFilesHandle() async {
    setState(() {
      fileElements.clear();
      _setStringStatus();
    });
  }

  Future _saveFilesHandle() async {
    waitFilesId = Queue.of(fileElements.where((x) => x.status == FileStatuses.waiting)
                                       .map((x) => x.id)
                                       .toList());

    var firstNTasks = waitFilesId.take(countLoadingFiles)
                                 .map((e) => _nextOperation());

    Future.wait(firstNTasks).whenComplete(() async {
      // Notify
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, channelName, channelDesription,
        importance: Importance.Max,
        priority: Priority.Default);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flnp.show(
        0,
        'Информация',
        'Файлы сохранены',
        platformChannelSpecifics,
        payload: 'Default_Sound',
      );
    });
  }

  Future _nextOperation() async {
    var delaySec = _r.nextInt(boundsDelay.last - boundsDelay.first) + boundsDelay.first;
    if (waitFilesId.isEmpty) {
      return;
    }
    var id = waitFilesId.removeFirst();
    setState(() {
      if (fileElements.isNotEmpty) {
        var loadEl = fileElements.firstWhereOrNull((el) => el.id == id);
        if (loadEl != null) {
          loadEl.status = FileStatuses.loading;
        }
      }
      _setStringStatus();
    });
    await Future.delayed(Duration(seconds: delaySec), () {
      setState(() {
        if (fileElements.isNotEmpty) {
          var completeEl = fileElements.firstWhereOrNull((el) => el.id == id);
          if (completeEl != null) {
            completeEl.status = FileStatuses.completed;
          }
        }
        _setStringStatus();
      });
    }).then((value) async {
      if (waitFilesId.isNotEmpty) {
        await _nextOperation();
      }
    });
  }

  void _setStringStatus() {
    setState(() {
      if (fileElements.isEmpty) {
        statusFiles = 'Нет файлов';
      }
      else if (fileElements.every((element) => element.status == FileStatuses.completed)) {
        statusFiles = 'Кол-во файлов: ${fileElements.length}';
      }
      else {
        var notCompletedFiles = fileElements.where((element) => element.status != FileStatuses.completed).length;

        statusFiles = 'Осталось загрузить: $notCompletedFiles.\nВсего файлов: ${fileElements.length}';
      }
    });
  }
}
