import 'package:flutter/material.dart';
import 'package:test_mintrocket/models/FileElement.dart';

class FilesView extends StatelessWidget {
  final FileElement file;
  final Function removeElement;

  FilesView(this.file, this.removeElement);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.name),
      subtitle: Text(_getFullNameByStatus(file.status)),
      trailing: IconButton(
        onPressed: () {
          removeElement();
        },
        icon: Icon(
          Icons.clear,
          size: 36
        ),
      )
    );
  }
}

// ignore: missing_return
String _getFullNameByStatus(FileStatuses status) {

  switch(status) {
    case FileStatuses.loading:
      return "Загружается";
    case FileStatuses.completed:
      return "";
    case FileStatuses.waiting:
      return "В ожидании";
  }
}