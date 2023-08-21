import 'dart:convert';
import 'package:events_streaming_platform/classes/nav_drawer.dart';
import 'package:events_streaming_platform/widgets/add_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../request/request.dart';
import '../widgets/message_widget.dart';

class ChatScreen extends StatefulWidget {
  static int talkId = 24;
  late double height;
  bool isFirstBuild = true;
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final WebSocketChannel channel;
  late Stream<dynamic> stream;
  String? chatKey;
  List<Message> messages = [Message('')];
  @override
  void initState() {
    Request.getChatKey(context).then((value) {
      chatKey = value;
      print('chat key $chatKey');
      var uri = Uri.parse(
        'ws://192.168.1.9:8080/ws/chats/talks/${ChatScreen.talkId}/?token=$chatKey',
      );
      try {
        channel = WebSocketChannel.connect(uri);
      } catch (error) {
        print(error);
      }
      print('init state');
      setState(() {});
    });

    super.initState();
  }

  void refreshConnection() {
    Request.getChatKey(context).then((value) {
      chatKey = value;
      print('chat key $chatKey');
      var uri = Uri.parse(
        'ws://192.168.1.9:8080/ws/chats/talks/${ChatScreen.talkId}/?token=$chatKey',
      );
      try {
        channel = WebSocketChannel.connect(uri);
      } catch (error) {
        print(error);
        showSanckBarMessage('an error occured try to refresh \n$error');
      }
      print('init state');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFirstBuild) {
      widget.height = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.bottom -
          140; // the height of the addMessageWidget 50
      widget.isFirstBuild = false;
      print('the widget is firstBuilt');
    }
    print('widget build');
    return Scaffold(
      drawer: NavDrawer.getDrawer(context, '', '', '', false),
      appBar: AppBar(
        title: const Text('chat screen'),
        actions: [
          IconButton(
            onPressed: refreshConnection,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: chatKey != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          json.decode(snapshot.data)['message'] !=
                              messages[messages.length - 1].content) {
                        //checking that the message recieved is not the same as the last message not to cause the rebuild of the widget when the keyboard is on or off
                        var data = json.decode(snapshot.data);
                        messages.add(Message(data['message']));
                        print('message recieved');
                      }
                      return SizedBox(
                        height: widget.height,
                        child: ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (_, idx) {
                            return Container(
                              margin: const EdgeInsets.all(5),
                              child: MessageWidget(message: messages[idx]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  AddMessageWidget(onPressed: (value) {
                    channel.sink.add(json.encode({'message': value}));
                  }),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void showSanckBarMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
