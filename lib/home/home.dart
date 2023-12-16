import 'dart:io';
import 'dart:typed_data';
import './../models/device.dart';
import 'package:flutter/material.dart';
import 'device_tile.dart';
//import 'package:screen/screen.dart';
import 'package:wakelock/wakelock.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool called = false;
  void server() async {
    if (called) {
      return;
    }
    called = true;
    // bind the socket server to an address and port
    Wakelock.enable();
    //Screen.keepOn(true);
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

    // listen for clent connections to the server
    server.listen((client) {
      handleConnection(client);
    });
  }

  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    // listen for events from the client
    client.listen(
      // handle data from the client
      (Uint8List data) async {
        await Future.delayed(Duration(seconds: 1));
        final message = String.fromCharCodes(data);
        setState(() {
          Device d = new Device(
              ip: client.remoteAddress.address,
              num: message,
              time: DateTime.now());
          dynamic j;
          for (var i in devices) {
            if (i.num == message) {
              j = i;
              break;
            }
          }
          devices.remove(j);
          devices.add(d);
        });
        client.close();
      },

      // handle errors
      onError: (error) {
        print(error);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        client.close();
      },
    );
  }

  List devices = [];
  @override
  Widget build(BuildContext context) {
    var reversedList = new List.from(devices.reversed);
    server();
    return Scaffold(
      appBar: AppBar(
        title: Text("اشعارات"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return DeviceTile(device: reversedList[index]);
        },
      ),
    );
  }
}
