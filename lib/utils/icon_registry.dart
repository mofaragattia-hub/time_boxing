import 'package:flutter/widgets.dart';

// A registry of known material icon codepoints mapped to const IconData
// entries. Using const IconData ensures the icon glyphs are retained by the
// Flutter icon tree-shaker during AOT builds.
const Map<int, IconData> kMaterialIconMap = {
  // default categories used in CategoryProvider
  0xe8f9: IconData(0xe8f9, fontFamily: 'MaterialIcons'), // work
  0xe7fd: IconData(0xe7fd, fontFamily: 'MaterialIcons'), // person
  0xe80c: IconData(0xe80c, fontFamily: 'MaterialIcons'), // school
  0xe3f6: IconData(0xe3f6, fontFamily: 'MaterialIcons'), // health

  // common UI icons (kept to avoid accidental tree-shake)
  0xe145: IconData(0xe145, fontFamily: 'MaterialIcons'), // add
  0xe3c9: IconData(0xe3c9, fontFamily: 'MaterialIcons'), // edit
};
