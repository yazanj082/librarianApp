import 'dart:convert';
import './../models/device.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceTile extends StatefulWidget {
  final Device device;

  DeviceTile({required this.device});

  @override
  _DeviceTileState createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  bool isToggled = false;

  @override
  void initState() {
    super.initState();
    getCurrentState();
  }

  Future<void> getCurrentState() async {
    final apiKeywrite = "W41VO7I9OCQDO46W";
    final apiKeyread = "I00RMQB7UMW6A3VO";
    final channelId = "2374629";

    var state = 1;
    final urlread = Uri.parse(
        "https://api.thingspeak.com/channels/$channelId/fields/2.json?api_key=$apiKeyread&results=1");

    final responseread = await http.post(urlread);

    if (responseread.statusCode == 200) {
      final jsonResponse = json.decode(responseread.body);
      final feeds = jsonResponse['feeds'];
      if (feeds.isNotEmpty) {
        final fieldValue = feeds[0]['field2'];
        state = int.tryParse(fieldValue) ?? 0;
      } else {
        throw Exception("No data available in the channel.");
      }
    } else {
      print("Error sending data to ThingSpeak: ${responseread.statusCode}");
    }

    setState(() {
      isToggled = (state != 0);
    });
  }

  Future<void> toggleThingSpeak() async {
    final apiKeywrite = "W41VO7I9OCQDO46W";
    final apiKeyread = "I00RMQB7UMW6A3VO";
    final channelId = "2374629";

    var state = isToggled ? 1 : 0;
    final newValue = state > 0 ? 0 : 1;

    final url = Uri.parse(
        "https://api.thingspeak.com/update.json?api_key=$apiKeywrite&field2=$newValue");

    final response = await http.post(url);

    if (response.statusCode == 200) {
      print("Data sent to ThingSpeak successfully");
      setState(() {
        isToggled = !isToggled;
      });
    } else {
      print("Error sending data to ThingSpeak: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.red,
          ),
          title: Text(
            '${widget.device.num}',
          ),
          subtitle: Text(
              'In  ${widget.device.time.hour - 12} : ${widget.device.time.minute} '),
          trailing: IconButton(
              icon: Icon(
                isToggled ? Icons.toggle_on : Icons.toggle_off,
                color: isToggled ? Colors.green : Colors.grey,
              ),
              onPressed: () async {
                await toggleThingSpeak();
              }),
        ),
      ),
    );
  }
}
