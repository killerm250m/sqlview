import 'package:flutter/material.dart';
import 'conf.dart';
import 'home.dart';
import 'crudview/crudview.dart';
import 'listview/listview.dart';
import 'package:dataview/dataview.dart';

final routes = {
  '/home': (BuildContext context) => HomePage(),
  '/crudview': (BuildContext context) => CrudPage(),
  '/listview': (BuildContext context) => ListViewPage(),
  '/dataview': (BuildContext context) =>
      DataviewPage("/", uploadTo: "http://192.168.1.2:8082/upload"),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sql view Demo',
      home: HomePage(),
      routes: routes,
    );
  }
}

void main() {
  initConf();
  runApp(MyApp());
}
