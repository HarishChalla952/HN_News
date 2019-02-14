import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

void main() => runApp(MyApp());

/*
final dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];
*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HN News'),
        backgroundColor: Colors.orangeAccent[700],),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('news').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 2.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(0.5),
          color: Colors.orange[50],
        ),
        child: ListTile(
          title: new Text.rich(
              recordTitles(record.id, record.name, record.url)),
          /*subtitle: Text(record.url),*/
          subtitle: new Text.rich(recordSubTitles(record.votes, record.by)),
          //trailing: Text(record.votes.toString()),
          onTap: () {
            openUrl(record.url);
          },
        ),
      ),
    );
  }

  TextSpan recordTitles(int id, String name, String url) {
    return new TextSpan(
        style: new TextStyle(fontSize: 14.0, color: Colors.black),
        text: "$id\.$name",
        children: <TextSpan>[
          new TextSpan(
              style: new TextStyle(fontSize: 12.0, color: Colors.grey),
              text: "($url)"
          )
        ]
    );
  }


  TextSpan recordSubTitles(int votes, String by,) {
    return new TextSpan(
      style: new TextStyle(fontSize: 12.0, color: Colors.grey),
      text: "$votes points by $by",
    );
  }

  void openUrl(String url) async {
    if (url != null && url.isNotEmpty && await urlLauncher.canLaunch(url)) {
      await urlLauncher.launch(url);
    }
  }
}

class Record {
  final String name;
  final int votes;
  final String url;
  final int id;
  final String by;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        assert(map['url'] != null),
        assert(map['id'] != null),
        assert(map['by'] != null),
        name = map['name'],
        votes = map['votes'],
        url = map['url'],
        id = map['id'],
        by = map['by'];


  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes:$url>";
}