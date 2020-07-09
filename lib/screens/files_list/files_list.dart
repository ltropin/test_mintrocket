import 'package:flutter/material.dart';

import 'package:test_mintrocket/models/FileElement.dart';
import '../../constants.dart';
import 'components/files_view.dart';

class FilesList extends StatefulWidget {

  @override
  _FilesListState createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Файлы'),
        centerTitle: true
      ),
      body: _getFilesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isDisableAddFileBut() ? null : _addFileHandle,
        child: const Icon(Icons.add),
        backgroundColor: _isDisableAddFileBut() ? Colors.grey : Colors.blue,
      ),
    );
  }

  bool _isDisableAddFileBut(){
    return fileElements.length >= maxFiles;
  }

  void _addFileHandle() {
    setState(() {
      fileElements.add(FileElement(
        name: 'Файл ${DateTime.now().hashCode}',
        status: FileStatuses.waiting
      ));
    });
  }

  void removeElement(int index) {
    setState(() {
      fileElements.removeAt(index);
    });
  }

  Widget _getFilesList() {
    if (fileElements.length == 0) {
      return Center(
        child: Text('Нет файлов', style: TextStyle(fontSize: 18),),
      );
    }
    
    return ListView.builder(
      itemBuilder: (context, index) => FilesView(fileElements.toList()[index], () => removeElement(index)),
      itemCount: fileElements.length,
    );
  }
}