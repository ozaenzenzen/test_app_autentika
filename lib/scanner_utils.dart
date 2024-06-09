// // Copyright 2019 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'dart:async';
// // import 'dart:typed_data';
// import 'dart:ui';

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:google_ml_vision/google_ml_vision.dart';

// class ScannerUtils {
//   ScannerUtils._();

//   static Future<CameraDescription> getCamera(CameraLensDirection dir) async {
//     return availableCameras().then(
//       (List<CameraDescription> cameras) => cameras.firstWhere(
//         (CameraDescription camera) => camera.lensDirection == dir,
//       ),
//     );
//   }

//   static Future<dynamic> detect({
//     required CameraImage image,
//     required Future<dynamic> Function(InputImage image) detectInImage,
//     required int imageRotation,
//   }) async {
//     return detectInImage(
//       InputImage.fromBytes(
//         bytes: _concatenatePlanes(image.planes),
//         metadata: _buildMetaData(
//           image,
//           rotationIntToImageRotation(imageRotation),
//         ),
//       ),
//     );
//   }

//   static Uint8List _concatenatePlanes(List<Plane> planes) {
//     final WriteBuffer allBytes = WriteBuffer();
//     for (var plane in planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     return allBytes.done().buffer.asUint8List();
//   }

//   static InputImageMetadata _buildMetaData(
//     CameraImage image,
//     InputImageRotation rotation,
//   ) {
//     final plane = image.planes.first;
//     return InputImageMetadata(
//       // format: image.format.raw,
//       format: InputImageFormatValue.fromRawValue(image.format.raw)!,
//       size: Size(
//         image.width.toDouble(),
//         image.height.toDouble(),
//       ),
//       rotation: rotation,
//       bytesPerRow: plane.bytesPerRow,
//       // planeData: image.planes.map(
//       //   (Plane plane) {
//       //     return GoogleVisionImagePlaneMetadata(
//       //       bytesPerRow: plane.bytesPerRow,
//       //       height: plane.height,
//       //       width: plane.width,
//       //     );
//       //   },
//       // ).toList(),
//     );
//   }

//   static InputImageRotation rotationIntToImageRotation(int rotation) {
//     switch (rotation) {
//       case 0:
//         return InputImageRotation.rotation0deg;
//       case 90:
//         return InputImageRotation.rotation90deg;
//       case 180:
//         return InputImageRotation.rotation180deg;
//       default:
//         assert(rotation == 270);
//         return InputImageRotation.rotation270deg;
//     }
//   }
// }
