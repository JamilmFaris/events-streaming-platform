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
  bool isGetarguments = false;
  bool isGetMyUpcomingEvents = false;
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    String? arguments;
    if (widget.isGetarguments) {
      arguments = ModalRoute.of(context)!.settings.arguments as String?;
    }
    if (arguments != null && arguments == 'logout') {
      setState(() {
        widget.firstBuild = true;
        widget.isGetarguments = true;
      });
    }

    if (widget.firstBuild) {
      CurrentUser.getUser().then((user) {
        Token.getToken().then((token) {
          if (user != null && token != null) {
            setState(() {
              widget.drawer = NavDrawer.getDrawer(
                context,
                user.username,
                user.email ?? '',
                user.avatar ?? '',
                true,
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
                widget.isGetMyUpcomingEvents
                    ? 'get Published Events'
                    : 'get My upcoming events',
                style: const TextStyle(
                  fontSize: 10,
                  color: TwColors.white,
                ),
              ),
              Switch(
                  value: widget.isGetMyUpcomingEvents,
                  onChanged: (value) {
                    setState(() {
                      widget.isGetMyUpcomingEvents =
                          !widget.isGetMyUpcomingEvents;
                    });
                  }),
            ],
          ),
        ],
      ),
      backgroundColor: TwColors.backgroundColor(context),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.isGetMyUpcomingEvents
                      ? 'My upcoming events'
                      : 'Published Events',
                  style: const TextStyle(fontSize: 25),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.isGetMyUpcomingEvents
                        ? PaginatedEventsWidget(
                            key: const ValueKey(1),
                            getEventsRequest: Request.getMyUpcomingEvents,
                            isEdit: false,
                          )
                        : PaginatedEventsWidget(
                            key: const ValueKey(2),
                            getEventsRequest: Request.getPublishedEvents,
                            isEdit: false,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
