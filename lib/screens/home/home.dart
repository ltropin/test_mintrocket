import 'dart:collection';
import 'dart:math';

import 'package:computer/computer.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_mintrocket/constants.dart';
import 'package:test_mintrocket/models/FileElement.dart';
import 'package:test_mintrocket/screens/files_list/files_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String statusFiles = "";

  @override
  void initState() {
    super.initState();
    _setStringStatus();
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
                      color: _isDisableResetBut() ? Colors.grey : Colors.black
                    )
                  ),
                  onPressed: _isDisableResetBut() ? null : _resetFilesHandle
                ),
                Spacer(),
                FlatButton(

                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      color: _isDisableSaveBut() ? Colors.grey : Colors.black
                    )
                  ),
                  onPressed: _isDisableSaveBut() ? null : _saveFilesHandle
                )
              ],
            )
          )
        ],
      )
    );
  }

  void _resetFilesHandle() {
    setState(() {
      fileElements.clear();
      _setStringStatus();
    });
  }

  Future _saveFilesHandle() async {
    var waitFilesIndex = Queue.of(fileElements.asMap()
                                              .keys
                                              .where((x) => fileElements[x].status == FileStatuses.waiting)
                                              .toList());
    int currentOperations = 0;
    var r = Random();
    while(waitFilesIndex.length > 0) {
      if (currentOperations <= countLoadingFiles) {
          var delaySec = r.nextInt(boundsDelay.last - boundsDelay.first) + boundsDelay.first;
          var index = waitFilesIndex.removeFirst();
          setState(() {
            if (fileElements.isNotEmpty) {
              fileElements[index].status = FileStatuses.loading;
            }
            _setStringStatus();
            currentOperations++;
            });
            await Future.delayed(Duration(seconds: delaySec), () {
              setState(() {
                if (fileElements.isNotEmpty) {
                  fileElements[index].status = FileStatuses.completed;
                }
                _setStringStatus();
                currentOperations--;
            });
          });
      }
    }
  }

  bool _isDisableResetBut() {
    return fileElements.isEmpty;
  }

  bool _isDisableSaveBut() {
    return fileElements.isEmpty || fileElements.any((e) => e.status == FileStatuses.loading);
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
