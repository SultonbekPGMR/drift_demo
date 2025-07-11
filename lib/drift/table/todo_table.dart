import 'package:drift/drift.dart';

class TodoItems extends Table{
  IntColumn get id => integer().autoIncrement().call();
  TextColumn get title => text()();
  TextColumn get description => text().named('body')();

}