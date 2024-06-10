import 'dart:typed_data';

import 'package:uno_active_liveness/uno_active_liveness.dart';

class SupportGetXFrame {
  List<ByteData> frames;
  int xFrame;

  SupportGetXFrame({
    required this.frames,
    required this.xFrame,
  });
}

List<Uint8List> getXFrameV2(SupportGetXFrame data) {
  return UnoActiveLiveness().getXFrame(data.frames, data.xFrame);
}
