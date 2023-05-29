import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class DetailsImage extends StatelessWidget {
  final GlobalKey genKey = GlobalKey();

  DetailsImage({super.key}){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { print(timeStamp); });
  }

  Future<void> takePicture() async {
    RenderRepaintBoundary boundary = genKey.currentContext as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/photo.png');
    await imgFile.writeAsBytes(pngBytes);
    print(imgFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: genKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("none"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),

              ElevatedButton(
                  onPressed: () async {
                    await takePicture();
                  },
                  child: Text(
                    "Take Picture",
                  ))
            ],
          ),
        ),
      ),
    );
  }
}