import 'package:meta/meta.dart';

enum FileStatuses {
  completed,
  loading,
  waiting
}

class FileElement {
  FileStatuses status;
  String name;
  int id;

  FileElement({@required this.name, @required this.status, @required this.id});
}


List<FileElement> fileElements = [];