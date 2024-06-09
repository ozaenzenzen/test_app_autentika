import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class Helper {
  static Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static ByteData concatenatePlanesByteData(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done();
  }

  static ByteData concatenatePlanesByteData2(List<Plane> planes) {
    List<Uint8List> conv = planes.map((e) {
      return e.bytes;
    }).toList();
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in conv) {
      allBytes.putUint8List(plane);
    }
    return allBytes.done();
  }
}
