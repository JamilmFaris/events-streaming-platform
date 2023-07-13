import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:events_streaming_platform/providers/paginated_events.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_edit_widget.dart';
import 'event_widget.dart';

class PaginatedEventsWidget extends StatefulWidget {
  bool isEdit;
  Future<List<Event>> Function({
    BuildContext? context,
    required int offset,
    required int limit,
  }) getEventsRequest;
  PaginatedEventsWidget({
    required this.getEventsRequest,
    required this.isEdit,
    super.key,
  });

  @override
  State<PaginatedEventsWidget> createState() => _PaginatedEventsWidgetState();
}

class _PaginatedEventsWidgetState extends State<PaginatedEventsWidget> {
  var event = Event(
    id: 1,
    title: 'title',
    organizerName: 'organizerName',
    description: 'description',
    picture: "https://loremflickr.com/320/240/dog",
    date: DateTime.now(),
    isPublished: false,
  );
  static const _LIMIT = 10;
  late PagingController<int, Event> _pagingController;
  PaginatedEvents _paginatedEvents = PaginatedEvents();

  @override
  void initState() {
    print('init');
    _pagingController = PagingController<int, Event>(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await widget.getEventsRequest(
        context: context,
        offset: _paginatedEvents.currentIndex,
        limit: _LIMIT,
      );
      final isLastPage = newItems.length < _LIMIT;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, Event>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Event>(
          itemBuilder: (context, event, index) => SizedBox(
            height: 200,
            child: (widget.isEdit)
                ? EventEditWidget(event: event)
                : EventWidget(event: event),
          ),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
