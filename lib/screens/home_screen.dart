import 'package:events_streaming_platform/models/current_user.dart';
import 'package:events_streaming_platform/models/token.dart';
import 'package:events_streaming_platform/widgets/paginated_events_widget.dart';
import 'package:flutter/material.dart';

import '../classes/nav_drawer.dart';
import '../design/tw_colors.dart';
import '../request/request.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/';
  Drawer? drawer;
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  bool firstBuild = true;
  bool getarguments = true;
  bool getMyUpcomingEvents = false;
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    print('home rebuilt ${widget.firstBuild}');
    String? arguments;
    if (widget.getarguments) {
      arguments = ModalRoute.of(context)!.settings.arguments as String?;
    }
    if (arguments != null && arguments == 'logout') {
      print(arguments);
      setState(() {
        widget.firstBuild = true;
        widget.getarguments = false;
      });
    }

    if (widget.firstBuild) {
      CurrentUser.getUser().then((user) {
        Token.getToken().then((token) {
          if (user != null) {
            setState(() {
              widget.drawer = NavDrawer.getDrawer(
                context,
                user.username,
                user.email ?? '',
                user.avatar ?? '',
                (token != null),
              );
            });
          } else {
            setState(() {
              widget.drawer = NavDrawer.getDrawer(
                context,
                '',
                '',
                '',
                false,
              );
            });
          }
        });
      });
      widget.firstBuild = false;
    }
    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Text(
                widget.getMyUpcomingEvents
                    ? 'get Published Events'
                    : 'get My upcoming events',
                style: const TextStyle(
                  fontSize: 10,
                  color: TwColors.white,
                ),
              ),
              Switch(
                  value: widget.getMyUpcomingEvents,
                  onChanged: (value) {
                    setState(() {
                      widget.getMyUpcomingEvents = value;
                    });
                  }),
            ],
          ),
        ],
      ),
      backgroundColor: TwColors.backgroundColor(context),
      body: Column(
        children: [
          Text(
            widget.getMyUpcomingEvents
                ? 'My upcoming events'
                : 'Published Events',
            style: const TextStyle(fontSize: 25),
          ),
          PaginatedEventsWidget(
            getEventsRequest: widget.getMyUpcomingEvents
                ? Request.getMyUpcomingEvents
                : Request.getPublishedEvents,
          ),
        ],
      ),
    );
  }
}
