import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as precLocation;
import 'package:image/image.dart' as img;
import 'package:image/image.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';

class CompressImage {
  String waterMarkText = "Nao informado";
  String newPath = "";
  late Uint8List asUint8List;
  Location location = Location();

  CompressImage();

  Future<void> compressAndGetFile(String path) async {
    final fontZipFile = await rootBundle.load('assets/orbitron-bigger.zip');
    asUint8List = fontZipFile.buffer.asUint8List();
    var file = File(path);
    final Directory tempDir = await getTemporaryDirectory();
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    try {
      await resizeImage(path);

      int col = image!.height - 300;
      int row = 100;

      int col2 = image.height - 200;
      int row2 = 100;
      LocationData data = await getLocation();

      waterMarkText =
          await getAddressFromLatLong(data.latitude!, data.longitude!);

      final logo = img.Image(width: image.width, height: 200);
      img.drawString(logo, waterMarkText,
          font: BitmapFont.fromZip(asUint8List), x: 10, y: 10);
      await img.encodePngFile('${tempDir.path}/testFont.png', image);

      log(row.toString());

      //img.drawString(image!, arial_24, 100, 200, wateMarktext);
      //img.fillRect(image,100, 200, 0, 0, 000000);

      img.drawString(
          image,
          font: BitmapFont.fromZip(asUint8List),
          x: row,
          y: col,
          waterMarkText);

      img.drawString(
          image,
          font: BitmapFont.fromZip(asUint8List),
          x: row2,
          y: col2,
          DateTime.now().toIso8601String());

      final outImage = img.encodeJpg(image);

      await File(path).writeAsBytes(outImage);
    } catch (error, stackTrace) {
      log("Error Photo", error: error, stackTrace: stackTrace);
    }

    // print("Tamanho Saida : ${outlenght.toString()}");
  }

  Future getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    return locationData;
  }

  Future<String> getAddressFromLatLong(
      double latitude, double longitude) async {
    List<precLocation.Placemark> placemarks =
        await precLocation.placemarkFromCoordinates(latitude, longitude);
    print(placemarks);
    precLocation.Placemark place = placemarks[0];
    var address =
        "${place.street} ${place.subThoroughfare}, ${place.subLocality} ";

    return address;
  }

  Future<void> resizeImage(String filePath) async {
    try {
      final file = File(filePath);

      final bytes = await file.readAsBytes();
      if (kDebugMode) {
        print("Picture original size: ${bytes.length}");
      }

      final image = img.decodeImage(bytes);
      final resized = img.copyResize(image!, width: 720, height: 1280);
      final resizedBytes = img.encodeJpg(resized, quality: 30);
      if (kDebugMode) {
        print("Picture resized size: ${resizedBytes.length}");
      }

      await file.writeAsBytes(resizedBytes);
    } catch (error, stackTrace) {
      log("Error", error: error, stackTrace: stackTrace);
    }
  }
}
