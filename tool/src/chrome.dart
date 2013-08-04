library nv.tool.chrome;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_io/bot_io.dart';

// TODO: use an environment variable for this?
const _chromePath = '/Users/kevin/source/dev/Google Chrome.app/Contents/MacOS/Google Chrome';

Future launchChrome() {
  var testLaunch =
    {
     'load-and-launch-app': 'test',
     'no-startup-window': null,
     'enable-logging': 'stderr',
     'v': '1'
    };

  return TempDir
      .then((dir) => _launchChrome(dir, testLaunch))
      .then((int exitCode) {
        if(exitCode != 0) {
          throw 'process failed';
        }
      });
}

Future<int> _launchChrome(Directory tempDir, [Map<String, String> argsMap]) {

  if(argsMap == null) {
    argsMap = {};
  }
  argsMap['user-data-dir'] = tempDir.path;
  argsMap['no-default-browser-check'] = null;
  argsMap['no-first-run'] = null;

  var args = argsMap.keys.map((key) {
    assert(!key.startsWith('-'));
    var value = argsMap[key];

    var str = "--$key";
    if(value == null) {
      return str;
    } else {
      return "$str=$value";
    }
  }).toList(growable: false);

  print(args);

  return Process.start(_chromePath, args)
      .then((Process process) {

        _captureStd(false, process.stdout);
        _captureStd(true, process.stderr);

        return process.exitCode;
      });
}

void _captureStd(bool process, Stream<List<int>> std) {

  std.transform(UTF8.decoder)
    .listen((String value) {
    if(process) {
      _print('parsed', AnsiColor.RED);
      print(value);
    }
  }, onDone: () {
    // done!
  });
}

void _print(String value, [AnsiColor color]) {
  if(color != null) {
    var ss = new ShellString.withColor(value, color);
    value = ss.format(true);
  }
  print(value);
}
