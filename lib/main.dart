import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velocity_x/velocity_x.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SmsMessage> messages = [];
  ByteData? font;
  String? filePath;
  @override
  void initState() {
    super.initState();
    requestSmsPermission();
  }

  Future<void> requestSmsPermission() async {
    var status = await Permission.sms.request();
    if (status == PermissionStatus.granted) {
      font = await rootBundle.load('assets/KrutiiDev.ttf');
      // Permission granted, fetch SMS messages
      fetchSmsMessages();
    } else {
      // Permission denied, handle accordingly
      print("SMS permission denied");
    }
  }

  Future<void> fetchSmsMessages() async {
    try {
      SmsQuery query = SmsQuery();
      List<SmsMessage> smsList = await query.getAllSms;
      setState(() {
        messages = smsList;
      });
      exportToPdf();
    } catch (e) {
      print("Error fetching SMS messages: $e");
    }
  }

  Future<void> exportToPdf() async {
    List smsLt = [
      ["Data", "Sender", "Message"],
    ];
    for (var i = 0; i < messages.length; i++) {
      smsLt.add([
        messages[i].date,
        messages[i].body,
        messages[i].body,
      ]);
    }
    final Directory? downloadsDir = await getDownloadsDirectory();
    // Save the PDF to a file
    final output = File('${downloadsDir?.path}/sms_messages.csv');

    output.writeAsString(smsLt.toString()).then(
        (value) => VxToast.show(context, msg: 'saved to: ${output.path}'));
    setState(() {
      filePath = output.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Extractor'),
      ),
      body: [
        "Path of saved file: ".text.make(),
        ListView.builder(
          itemCount: messages.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(messages[index].body!),
              subtitle: Text('From: ${messages[index].address}'),
            );
          },
        )
      ].vStack(),
    );
  }
}
