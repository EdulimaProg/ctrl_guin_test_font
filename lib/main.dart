import 'dart:async';
import 'dart:io';

import 'package:ctrl_guin_test_font/compress_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamController imageController = StreamController();
  String path = "";

  Future takePhoto(context) async {
    imageController.sink.add(null);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    path = image!.path;
    
   // var myLocation = await getLocation();
    

    await CompressImage().compressAndGetFile(path);


    if (image.path.isNotEmpty) {
      imageController.sink.add(path);
    } else {
      imageController.sink.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
                stream: imageController.stream,
                builder: (_, value) {
                  if (value.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(50),
                      child: Image(image: FileImage(File(value.data!))),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: ElevatedButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          onPressed: () => takePhoto(context),
          child: const Text('Tirar Foto'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Directory {}
