import 'dart:isolate';
import 'dart:ui';

class AudioIsolateInit {
  final SendPort sendPort;
  final RootIsolateToken rootToken;

  AudioIsolateInit(this.sendPort, this.rootToken);
}
