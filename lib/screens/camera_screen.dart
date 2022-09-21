import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/screens/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class CustomCamera extends StatefulWidget {
  // const CustomCamera({Key? key, super(Key: key)});

  // final List<CameraDescription>? cameras;
  // final Color? color;
  // final Color? iconColor;
  // Function(XFile)? onImageCaptured;
  // Function(XFile)? onVideoRecorded;
  // final Duration? animationDuration;

  // CustomCamera(
  //     {Key? key,
  //     this.onImageCaptured,
  //     this.animationDuration = const Duration(seconds: 1),
  //     this.onVideoRecorded,
  //     this.iconColor = Colors.white70,
  //     required this.color})
  //     : super(key: key);

  @override
  _CustomCameraState createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera>
    with WidgetInspectorService {

  //use this to easily understand whether the camera is initialized and refresh the UI accordingly:
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  List<File> allFileList = [];

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;


  void setCamera(int index) {
    controller = CameraController(cameras[index], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  // 1.Initializing a new camera controller, which is needed to start the camera screen
  // 2.Disposing the previous controller and replacing it with a new controller that
  //   has different properties when the user flips the camera view or changes the
  //   quality of the camera
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    //resetCameraValues();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    getPermissionStatus();
    super.initState();
    // initCamera().then((_) {
    //   setCamera(0);
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  ///Camera Screen
  Widget cameraScreen() {
    return Stack(
      key: const ValueKey(1),
      children: [
        //Camera preview
        Positioned(
          top: 90,
          bottom: 60,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: RotatedBox(
              quarterTurns: 1 - controller!.description.sensorOrientation ~/ 90,
              child: CameraPreview(
                controller!,
              ),
            ),
          ),
        ),

        ///top controls
        Positioned(
            top: 0,
            height: 60,
            child: Container(
              height: 60,
              color: Colors.black,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ///Front Camera toggle
                  Icon(Icons.line_weight, color: Colors.white, size: 30,),
                  _isVideoCameraSelected
                      ? _isRecordingInProgress == false
                          ? const Text(
                              'Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 15,
                                  ),
                                  StreamBuilder<int>(
                                      stream: _stopWatchTimer.rawTime,
                                      initialData:
                                          _stopWatchTimer.rawTime.value,
                                      builder: (context, snapshot) {
                                        final value = snapshot.data;
                                        final displayTime =
                                            StopWatchTimer.getDisplayTime(
                                                value!,
                                                hours: false,
                                                milliSecond: false);
                                        return Text(
                                          displayTime,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        );
                                      }),
                                ],
                              ),
                            )
                      : const Text(
                          "Capturing...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),

                  ///Flash toggle
                  flashToggleWidget()
                ],
              ),
            )),

        ///Medium Bottom Controls
        Positioned(
          bottom: 60,
          height: 80,
          child: Container(
            // color: Colors.black,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _isRecordingInProgress
                      ? () async {
                          if (controller!.value.isRecordingPaused) {
                            await resumeVideoRecording();
                          } else {
                            await pauseVideoRecording();
                          }
                        }
                      : () {
                          setState(() {
                            _isCameraInitialized = false;
                          });
                          onNewCameraSelected(
                              cameras[_isRearCameraSelected ? 1 : 0]);
                          setState(() {
                            _isRearCameraSelected = !_isRearCameraSelected;
                          });
                        },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.black38,
                        size: 60,
                      ),
                      _isRecordingInProgress
                          ? controller!.value.isRecordingPaused
                              ? const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 30,
                                )
                          : Icon(
                              _isRearCameraSelected
                                  ? Icons.camera_front
                                  : Icons.camera_rear,
                              color: Colors.white,
                              size: 30,
                            ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _isVideoCameraSelected
                      ? () async {
                          if (_isRecordingInProgress) {
                            XFile? rawVideo = await stopVideoRecording();
                            File videoFile = File(rawVideo!.path);

                            int currentUnix =
                                DateTime.now().millisecondsSinceEpoch;

                            final directory =
                                await getApplicationDocumentsDirectory();

                            String fileFormat = videoFile.path.split('.').last;

                            _videoFile = await videoFile.copy(
                              '${directory.path}/$currentUnix.$fileFormat',
                            );

                            _startVideoPlayer();
                          } else {
                            await startVideoRecording();
                          }
                        }
                      : () async {
                          XFile? rawImage = await takePicture();
                          File imageFile = File(rawImage!.path);

                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();

                          String fileFormat = imageFile.path.split('.').last;

                          print(fileFormat);

                          await imageFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );

                          refreshAlreadyCapturedImages();
                        },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: _isVideoCameraSelected
                            ? Colors.white
                            : Colors.white38,
                        size: 80,
                      ),
                      Icon(
                        Icons.circle,
                        color:
                            _isVideoCameraSelected ? Colors.red : Colors.white,
                        size: 65,
                      ),
                      _isVideoCameraSelected && _isRecordingInProgress
                          ? const Icon(
                              Icons.stop_rounded,
                              color: Colors.white,
                              size: 32,
                            )
                          : Container(),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _imageFile != null || _videoFile != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(
                                imageFile: _imageFile!,
                                fileList: allFileList,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: videoController != null &&
                            videoController!.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.black,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 4.0,
                              bottom: 10,
                            ),
                            child: TextButton(
                              onPressed: _isRecordingInProgress
                                  ? null
                                  : () {
                                      if (_isVideoCameraSelected) {
                                        setState(() {
                                          _isVideoCameraSelected = false;
                                        });
                                      }
                                    },
                              style: TextButton.styleFrom(
                                foregroundColor: _isVideoCameraSelected
                                    ? Colors.black54
                                    : Colors.black,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white30
                                    : Colors.white,
                              ),
                              child: Text('IMAGE'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              right: 20.0,
                              bottom: 10,
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (!_isVideoCameraSelected) {
                                  setState(() {
                                    _isVideoCameraSelected = true;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _isVideoCameraSelected
                                    ? Colors.black
                                    : Colors.black54,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                              child: Text('VIDEO'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }

  bool _isTouchOn = false;

  Widget flashToggleWidget() {
    return IconButton(
      onPressed: () {
        if (_isTouchOn == false) {
          controller!.setFlashMode(FlashMode.torch);
          _isTouchOn = true;
        } else {
          controller!.setFlashMode(FlashMode.off);
          _isTouchOn = false;
        }
        setState(() {});
      },
      icon: Icon(_isTouchOn == false ? Icons.flash_on : Icons.flash_off,
          color: Colors.white, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? cameraScreen()
                : const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                const Text(
                  'Permission denied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    getPermissionStatus();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Give permission',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
