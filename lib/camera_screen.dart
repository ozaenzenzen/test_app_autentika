import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:test_app_authentika/helper.dart';
import 'package:uno_active_liveness/uno_active_liveness.dart';

class CameraScreen extends StatefulWidget {
  final Widget? captureButton;

  const CameraScreen({
    super.key,
    this.captureButton,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  GlobalKey cameraKey = GlobalKey();
  GlobalKey headerKey = GlobalKey();
  GlobalKey cameraWidgetKey = GlobalKey();

  static const platform = MethodChannel("uno_active_liveness");
  static const actionIndex = 0;

  bool isReceived = false;
  bool isMatch = false;

  CameraController? controller;

  List<CameraDescription>? cameras;
  CameraController? cameraController;

  double xRation = 3;
  double yRation = 4;

  @override
  void initState() {
    platform.setMethodCallHandler(onAnalyzedFrameReceived);
    // initCamera();
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  void initCamera() async {
    try {
      cameras = await availableCameras();
      var camera = cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
      );
      cameraController = CameraController(
        camera,
        ResolutionPreset.max,
        imageFormatGroup: (Platform.isAndroid) ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
        enableAudio: false,
      );
      cameraController!.initialize().then((_) async {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      await controller!.startImageStream((CameraImage availableImage) async {
        // _scanText(availableImage);
        debugPrint('stream start');
        debugPrint('availableImage.format ${availableImage.format}');
        debugPrint('availableImage.height ${availableImage.height}');
        debugPrint('availableImage.width ${availableImage.width}');
        debugPrint('availableImage.planes ${availableImage.planes}');
      });
    } catch (e) {
      debugPrint('error $e');
    }
  }

  Future<dynamic> onAnalyzedFrameReceived(MethodCall call) async {
    ActionValue actionValue = UnoActiveLiveness().getActionValue(call, actionIndex);
    if (isReceived) {
      if (isMatch) {
        debugPrint('Action is Match');
      } else {
        debugPrint('Action is not Match');
      }
    } else {
      debugPrint('Data is not received');
    }
  }
  

  List<Uint8List> getXFrame(List<ByteData> frames, int xFrame) {
    return UnoActiveLiveness().getXFrame(frames, xFrame);
  }

  Future<String?> launchLiveness(List<Uint8List> frames, int cameraWidth, int cameraHeight) async {
    return await UnoActiveLiveness().runInterpreter(frames, cameraWidth, cameraHeight);
  }

  final CameraLensDirection _direction = CameraLensDirection.front;

  Future<void> _initializeCamera() async {
    final CameraDescription description = await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == _direction,
      ),
    );

    // inputImageRotation = ScannerUtils.rotationIntToImageRotation(description.sensorOrientation);

    cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController!.initialize();

    setState(() {});

    await Future.delayed(const Duration(seconds: 2));
    await cameraController!.startImageStream((CameraImage image) async {
      debugPrint('stream start');
      debugPrint('image.format ${image.format.raw}');
      debugPrint('image.height ${image.height}');
      debugPrint('image.width ${image.width}');
      // debugPrint('image.planes ${image.planes[0].bytes}');

      // List<ByteData> newData = image.planes.map((e) {
      //   return ByteData.view(e.bytes.buffer);
      // }).toList();

      // await cameraController!.stopImageStream();

      List<ByteData> newData = [Helper.concatenatePlanesByteData2(image.planes)];

      debugPrint('newData ${newData[0].buffer.lengthInBytes}');

      var getXFrameData = getXFrame(newData, 4);
      // debugPrint('getXFrameData $getXFrameData');

      // launchLiveness(getXFrameData, image.width, image.height).then((value) {
      //   debugPrint('status sekarang $value');
      // }).whenComplete(() => null);

      var outputLiveness = await launchLiveness(getXFrameData, image.width, image.height);
      debugPrint('status sekarang ${outputLiveness}');

      await cameraController!.stopImageStream();
    });
  }

  Future<XFile?> takePicture() async {
    final CameraController? controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      // printDebug('Error: select a camera first.');
      return null;
    }

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await controller.takePicture();
      return file;
    } on CameraException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Menunggu camera",
            style: TextStyle(
              // color: Colors.green,
              fontSize: 40,
            ),
          ),
        ),
      );
    }
    if (!cameraController!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("camera"),
      ),
      body: Stack(
        children: [
          _cameraPreview(),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  key: headerKey,
                  color: Colors.black.withOpacity(0.65),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    30,
                  ),
                ),
                AspectRatio(
                  key: cameraKey,
                  aspectRatio: xRation / yRation,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.65),
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 40,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    if (cameraController != null) {
                      // onTakePicture(cameraController!);
                      takePicture();
                      debugPrint("kepencet");
                    } else {
                      debugPrint('camera Controller is null');
                    }
                  },
                  child: widget.captureButton ??
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkResponse(
                              onTap: () async {
                                takePicture();
                                debugPrint("kepencet");
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                alignment: Alignment.bottomCenter,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(6.81),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF6F6F6F),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                ),
                // const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        key: cameraWidgetKey,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CameraPreview(
          cameraController!,
        ),
      ),
    );
  }
}
