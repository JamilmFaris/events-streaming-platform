import 'dart:io';

import 'package:events_streaming_platform/classes/event_arguments.dart';
import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:events_streaming_platform/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../classes/auth_arguments.dart';
import '../classes/helper.dart';
import '../models/event.dart';
import '../request/request.dart';
import '../widgets/edit_talks_widget.dart';

class EditEventDetailsScreen extends StatefulWidget {
  Event event;
  EditEventDetailsScreen({required this.event, super.key});

  @override
  State<EditEventDetailsScreen> createState() => _EditEventDetailsScreenState();
}

class _EditEventDetailsScreenState extends State<EditEventDetailsScreen> {
  XFile? image;
  TextEditingController titleController = TextEditingController(),
      dateController = TextEditingController(),
      descriptionController = TextEditingController();
  DateTime? _selectedStartDate;
  bool isPublished = false;
  bool firstBuild = true;
  @override
  Widget build(BuildContext context) {
    isPublished = widget.event.isPublished;
    double imageWidth = 100, imageHeight = 100;
    Image addImage = Image.asset('assets/images/add_image.png');
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('event ${widget.event.title}'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 0.25 * screenSize.height,
                  width: 0.25 * screenSize.width,
                  child: GestureDetector(
                    onTap: pick,
                    child: image == null
                        ? Helper.getSizedImage(
                            addImage,
                            imageHeight,
                            imageWidth,
                          )
                        : Helper.getSizedImage(
                            Image.file(File(image!.path)),
                            imageHeight,
                            imageWidth,
                          ),
                  ),
                ),
                EditTalksWidget(
                  eventId: widget.event.id,
                  addTalkToParent: addTalk,
                  talks: widget.event.talks ?? [],
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(fontSize: 20),
                    hintText: 'title : ${widget.event.title}',
                  ),
                ),
                EventArguments.createDateButton(
                  onPressed: _presentStartDatePicker,
                  child: Text(_selectedStartDate == null
                      ? 'click to add date'
                      : 'Picked date : ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedStartDate!)}'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(fontSize: 20),
                    hintText: 'description : ${widget.event.description}',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('do you want to publish it '),
                    Switch(
                      value: isPublished,
                      onChanged: (value) {
                        setState(() {
                          isPublished = value;
                          widget.event.isPublished = value;
                        });
                      },
                    )
                  ],
                ),
                EventArguments.eventFilledButton(
                  onPressed: () {
                    Event before = widget.event;
                    int id = before.id;
                    String title = titleController.text.isEmpty
                        ? before.title
                        : titleController.text;
                    String description = descriptionController.text.isEmpty
                        ? before.description
                        : descriptionController.text;
                    DateTime date = _selectedStartDate ?? before.date;
                    XFile? eventImage = image;
                    Request.editEvent(
                      context,
                      id,
                      title,
                      description,
                      date,
                      null,
                      eventImage,
                      isPublished,
                    );
                    Navigator.pushNamed(context, HomeScreen.routeName);
                  },
                  child: const Text('edit event'),
                ),
                const SizedBox(height: 10),
                EventArguments.deleteButton(
                    onPressed: () async {
                      var result = await showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content:
                                const Text('are you sure you want to delete?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Handle 'Yes' button press
                                  Navigator.of(context).pop(
                                      true); // Return true to indicate 'Yes'
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle 'No' button press
                                  Navigator.of(context).pop(
                                      false); // Return false to indicate 'No'
                                },
                                child: const Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result) {
                        if (!mounted) return;
                        await Request.deleteEvent(context, widget.event.id);
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          HomeScreen.routeName,
                        );
                      }
                    },
                    child: const Text(
                      'delete event',
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addTalk(Talk talk) {
    setState(() {
      if (widget.event.talks == null) {
        widget.event.talks = [talk];
      } else {
        widget.event.talks?.add(talk);
      }
    });
  }

  Future<void> pick() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: AuthArguments.accountImageMaxSize.height,
        maxWidth: AuthArguments.accountImageMaxSize.width,
      );
      if (image == null) return;
      setState(() {
        this.image = image;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _presentStartDatePicker() async {
    //to test
    if (!context.mounted) {
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 7),
      ), //todo change to be for all the talks to be in interval of 7 days
    );
    if (picked != null) {
      if (!context.mounted) return;
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _selectedStartDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
        print(_selectedStartDate);
      }
    }
  }
}
