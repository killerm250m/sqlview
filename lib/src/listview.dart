import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlcool/sqlcool.dart';
import 'datatypes.dart';

class _InfiniteListViewState extends State<InfiniteListView> {
  _InfiniteListViewState(
      {@required this.db,
      @required this.table,
      this.columns = "*",
      this.where,
      this.orderBy,
      this.offset = 0,
      this.limit = 30,
      @required this.itemsBuilder,
      this.search = false,
      this.verbose = false})
      : _currentOffset = offset;

  final Db db;
  final String table;
  final String columns;
  final String where;
  final String orderBy;
  final int offset;
  final int limit;
  final ItemWidgetBuilder itemsBuilder;
  final bool verbose;
  final bool search;

  int _currentOffset;
  List<Map<String, dynamic>> _data = <Map<String, dynamic>>[];
  bool _ready = false;
  final _controller = TextEditingController();
  final _subject = PublishSubject<String>();

  Future<void> fetch({bool initial = false}) async {
    try {
      if (!initial) _currentOffset = _currentOffset + limit;
      //print("FETCH offset $_currentOffset");

      List<Map<String, dynamic>> res = await db.select(
          table: table,
          where: where,
          orderBy: orderBy,
          columns: columns,
          offset: _currentOffset,
          limit: limit,
          verbose: verbose);
      _data.addAll(res);
      //print("DATA $_data");
    } catch (e) {
      throw (e);
    }
  }

  @override
  void initState() {
    fetch(initial: true).then((_) => setState(() => _ready = true));
    _subject.stream
        .debounceTime(Duration(milliseconds: 500))
        .listen((dynamic text) {
      db
          .select(
              table: table,
              where: where,
              orderBy: orderBy,
              columns: columns,
              verbose: verbose)
          .then((res) {
        setState(() => _data = res);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) return const Center(child: Text("No data"));
    Widget w;
    _ready
        ? w = Column(children: <Widget>[
            if (search)
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                        controller: _controller,
                        onChanged: (text) => _subject.add(text),
                      )),
                      Icon(Icons.search)
                    ],
                  )),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                if (index < _data.length) {
                  //print("BUILD ITEM $index < ${_data.length}");

                  return itemsBuilder(context, _data[index]);
                } else {
                  if (index == _data.length) return const Text("");
                  //print("FETCH $index > ${_data.length}");
                  fetch().then((_) => setState(() {}));
                  return const Center(child: CircularProgressIndicator());
                }
              },
              itemCount: _data.length + 1,
            ))
          ])
        : w = const Center(child: CircularProgressIndicator());
    return w;
  }
}

/// The infinite list view widget
class InfiniteListView extends StatefulWidget {
  /// Default constructor
  InfiniteListView(
      {@required this.db,
      @required this.table,
      this.columns = "*",
      this.where,
      this.orderBy,
      this.offset = 0,
      this.limit = 30,
      @required this.itemsBuilder,
      this.verbose = false})
      : assert(db != null),
        assert(table != null);

  /// The sqlcool database to use
  final Db db;

  /// The table name
  final String table;

  /// The columns to include
  final String columns;

  /// The sql where clause
  final String where;

  /// The sql order_by clause
  final String orderBy;

  /// The sql offset value
  final int offset;

  /// The sql limit value
  final int limit;

  /// The function to build the content widgets
  final ItemWidgetBuilder itemsBuilder;

  /// Verbosity of the methdds
  final bool verbose;

  @override
  _InfiniteListViewState createState() => _InfiniteListViewState(
      db: db,
      table: table,
      columns: columns,
      where: where,
      orderBy: orderBy,
      offset: offset,
      limit: limit,
      itemsBuilder: itemsBuilder);
}
