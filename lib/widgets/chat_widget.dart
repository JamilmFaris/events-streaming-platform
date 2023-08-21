import 'dart:convert';

import 'package:events_streaming_platform/widgets/add_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../request/request.dart';
import 'message_widget.dart';

class ChatWidget extends StatefulWidget {
  final int talkId;
  late double height;
  bool isFirstBuild = true;
  ChatWidget({required this.talkId, super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final WebSocketChannel channel;
  late Stream<dynamic> stream;
  String? chatKey;
  List<Message> messages = [Message('', 'WELCOME')];
  @override
  void initState() {
    Request.getChatKey(context).then((value) {
      chatKey = value;
      print('chat key $chatKey');
      var uri = Uri.parse(
        'ws://${Request.authority}/ws/chats/talks/${widget.talkId}/?token=$chatKey',
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

  @override
  Widget build(BuildContext context) {
    if (widget.isFirstBuild) {
      widget.height = 2 * MediaQuery.of(context).size.height / 3 -
              MediaQuery.of(context).padding.bottom -
              70 // the height of the addMessageWidget 50
          ;

      widget.isFirstBuild = false;
    }
    print('widget build');
    return chatKey != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        (json.decode(snapshot.data)['message'] !=
                                messages[messages.length - 1].content ||
                            json.decode(snapshot.data)['username'] !=
                                messages[messages.length - 1].sender)) {
                      //checking that the message recieved is not the same as the last message not to cause the rebuild of the widget when the keyboard is on or off
                      var data = json.decode(snapshot.data);
                      messages.add(Message(data['username'], data['message']));
                      print(
                          'message recieved ${data['message']} user is ${data['username']}');
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
        : const Center(child: CircularProgressIndicator());
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
