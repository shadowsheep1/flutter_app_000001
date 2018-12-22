import 'dart:io';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:simple_permissions/simple_permissions.dart';

String selectedUrl = "https://flutter.io";
bool externalStoragePermissionOkay = false;
bool disableDebugPrint = false;

void main() => runApp(new MyApp());

void _disableDebugPrint() {
  if (disableDebugPrint) {
    debugPrint = (String message, {int wrapWidth}) {};
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _disableDebugPrint();
    final wordPair = new WordPair.random();
    return new MaterialApp(
      title: 'Welcome to Flutter',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      routes: {
        "/": (_) => new RandomWords(),
        "/widget": (_) => new WebviewScaffold(
              url: selectedUrl,
              appBar: new AppBar(
                title: new Text("Widget webview"),
              ),
              withZoom: true,
            )
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _saved = new Set<String>();

  final _biggerFont = const TextStyle(fontSize: 18.0);

  static const platform =
      const MethodChannel('it.versionestabile.flutterapp000001/pdfViewer');

  @override
  initState() {
    super.initState();
    _initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Pdf file list'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
            (file) {
              return new ListTile(
                title: new Text(
                  file,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
                context: context,
                tiles: tiles,
              )
              .toList();
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  /*
  getExternalStorageDirectory().then((Directory dir) {
  Directory pdfDir = new Directory(dir.path + "/pdf");
  pdfDir.list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) {
  print(entity.path);
  return _buildRow(entity.path);
  });
  });
  */

  Widget _buildDirectory(
      BuildContext context, AsyncSnapshot<Directory> snapshot) {
    Text text = const Text('');
    Directory dir;
    List<FileSystemEntity> _files;
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = new Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        dir = new Directory(snapshot.data.path + '/pdf/');
        text = new Text('path: ${dir.path}');
        _files = dir.listSync(recursive: true, followLinks: false);
      } else {
        text = const Text('path unavailable');
      }
    }
    if (null != _files) {
      return new ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _files.length,
          itemBuilder: (context, i) {
            return _buildRow(_files.elementAt(i).path);
          });
    } else {
      return new Padding(padding: const EdgeInsets.all(16.0), child: text);
    }
  }

  Widget _buildSuggestions() {
    if (Platform.isAndroid && externalStoragePermissionOkay) {
      return new FutureBuilder<Directory>(
          future: getExternalStorageDirectory(), builder: _buildDirectory);
    } else {
      return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text("You're not on Android"));
    }
  }

  Widget _buildRow(String fileName) {
    Future<Null> _launched;
    final alreadySaved = _saved.contains(fileName);
    return new ListTile(
      title: new Text(
        fileName,
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(fileName);
          } else {
            _saved.add(fileName);
          }
          File f = new File(fileName);
          selectedUrl = fileName; //f.uri.toString();
          //Navigator.of(context).pushNamed("/widget");
          var args = {'url': fileName};
          platform.invokeMethod('viewPdf', args);
        });
      },
    );
  }

  Future<Null> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  _initPlatformState() async {
    if (Platform.isAndroid) {
      SimplePermissions
          .checkPermission(Permission.WriteExternalStorage)
          .then((checkOkay) {
        if (!checkOkay) {
          SimplePermissions
              .requestPermission(Permission.WriteExternalStorage)
              .then((okDone) {
            if (okDone != null && okDone == PermissionStatus.authorized) {
              debugPrint("${okDone}");
              setState(() {
                externalStoragePermissionOkay = true;
                debugPrint('Refresh UI');
              });
            }
          });
        } else {
          setState(() {
            externalStoragePermissionOkay = checkOkay;
            debugPrint('Test');
          });
        }
      });
    }
  }
}
