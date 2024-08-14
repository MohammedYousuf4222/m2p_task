import 'package:flutter/cupertino.dart';
import 'package:itunes_media_app/res/Resources.dart';

extension AppContextExtension on BuildContext {
  Resources get resources => Resources.of(this);
}
