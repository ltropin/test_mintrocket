import 'package:meta/meta.dart';

enum FileStatuses {
  completed,
  loading,
  waiting
}

class FileElement {
  FileStatuses status;
  String name;

  FileElement({@required this.name, @required this.status});
}


List<FileElement> fileElements = [];