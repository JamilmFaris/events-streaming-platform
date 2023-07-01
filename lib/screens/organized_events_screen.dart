import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/event.dart';
import '../providers/paginated_events.dart';
import '../request/request.dart';
import '../widgets/paginated_events_widget.dart';

class OrganizedEventsScreen extends StatelessWidget {
  static const String routeName = '/organized-events';
  const OrganizedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(title: const Text('My organized events')),
      body: Column(children: [
        getPaginatedOrganizedEvents(
          context,
          'published',
          Request.getMyOrganizedPublishedEvents,
        ),
        getPaginatedOrganizedEvents(
          context,
          'unpublished',
          Request.getMyOrganizedUnPublishedEvents,
        ),
      ]),
    );
  }

  Widget getPaginatedOrganizedEvents(
    BuildContext context,
    String text,
    Future<List<Event>> Function(
            {BuildContext? context, required int limit, required int offset})
        function,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20,
              backgroundColor: TwColors.primaryColor(context),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: PaginatedEventsWidget(
                getEventsRequest: function,
                isEdit: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
