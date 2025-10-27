import 'dart:io';
import 'package:image/image.dart';

void main() {
  final candidates = ['assets/icon.png', 'lib/assets/icon.png'];
  String? inPath;
  for (final c in candidates) {
    if (File(c).existsSync()) {
      inPath = c;
      break;
    }
  }
  if (inPath == null) {
    stderr.writeln('No icon.png found in expected locations');
    exit(2);
  }
  final outPath = 'assets/icon_fixed.png';
  final bytes = File(inPath).readAsBytesSync();
  final img = decodeImage(bytes);
  if (img == null) {
    stderr.writeln('Failed to decode $inPath');
    exit(2);
  }

  final png = encodePng(img, level: 6);
  File(outPath).writeAsBytesSync(png);
  stdout.writeln('Wrote $outPath');
}
