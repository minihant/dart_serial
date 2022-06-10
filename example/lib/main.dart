// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:serial/serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SerialPort? _port;
  String tempMsg = '';
  String finalTxt = '';
  final scrollController = ScrollController();

  Future<void> _openPort() async {
    try {
      final port = await window.navigator.serial.requestPort();
      // await Future.delayed(const Duration(milliseconds: 1000));
      await port.open(SerialOptions(baudRate: 115200));
      // await Future.delayed(const Duration(milliseconds: 1000));
      _port = port;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> portClose() async {
    if (_port == null) {
      return;
    } else {
      await _port!.close();
    }
  }

  Future<void> _writeToPort() async {
    if (_port == null) {
      return;
    }
    final writer = _port!.writable.writer;
    await writer.ready;
    await writer.write(Uint8List.fromList('K009\r\n'.codeUnits));
    await writer.ready;
    await writer.close();
  }

  Future<void> _readFromPort() async {
    if (_port == null) {
      return;
    }
    final reader = _port!.readable.reader;
    while (true) {
      final result = await reader.read();
      final text = String.fromCharCodes(result.value);
      for (int i = 0; i < text.length; i++) {
        if (text[i] == '\n' || text[i] == '\n') {
          // _received.add(tempMsg);
          tempMsg += '\n';
          finalTxt += tempMsg;
          tempMsg = '';
        } else {
          tempMsg += text[i];
        }
      }
      setState(() {});
    }
  }

  Future<void> initPort() async {}
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Serial'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ElevatedButton(
            //   child: const Text('Open Port'),
            //   onPressed: () {
            //     _openPort();
            //   },
            // ),
            ListTile(
              onTap: () async {
                _openPort();
                setState(() {});
              },
              leading: const Icon(Icons.usb),
              title: const Text('Select Port'),
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () async {
                finalTxt = '';
                setState(() {});
              },
              leading: const Icon(Icons.clean_hands),
              title: const Text('clear'),
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   child: const Text('Send OK'),
            //   onPressed: () {
            //     _writeToPort();
            //   },
            // ),
            ListTile(
              onTap: () async {
                _readFromPort();
                finalTxt = 'Start';
                setState(() {});
              },
              leading: const Icon(Icons.usb),
              title: const Text('Open Log Window'),
            ),
            ListTile(
              onTap: () async {
                _writeToPort();
              },
              leading: const Icon(Icons.send),
              title: const Text('Send KeyOK'),
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () async {
                portClose();
              },
              leading: const Icon(Icons.close),
              title: const Text('port close'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                reverse: true, //focus stay at bottom
                scrollDirection: Axis.vertical,
                controller: scrollController,
                child: SelectableText(
                  finalTxt,
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
