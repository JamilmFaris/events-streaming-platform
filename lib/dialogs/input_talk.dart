import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../request/request.dart';

class InputTalk extends StatefulWidget {
  void Function(Talk) addTalk;
  int eventId;
  InputTalk({required this.eventId, required this.addTalk, super.key});

  @override
  State<InputTalk> createState() => _InputTalkState();
}

class _InputTalkState extends State<InputTalk> {
  final _talkTitleController = TextEditingController();
  final _speakerUserController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(
            left: 10,
            top: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'speaker username'),
                controller: _speakerUserController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'talk\'s title'),
                controller: _talkTitleController,
              ),
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _presentStartDatePicker,
                        child: Text(
                          _selectedStartDate == null
                              ? 'pick a start date'
                              : 'Picked date : ${DateFormat.yMd().format(_selectedStartDate!)}',
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: _presentEndDatePicker,
                        child: Text(
                          _selectedEndDate == null
                              ? 'pick an end date'
                              : 'Picked date : ${DateFormat.yMd().format(_selectedEndDate!)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submitData,
                style: Theme.of(context).elevatedButtonTheme.style,
                child: const Text('Add talk'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _presentStartDatePicker() async {
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
      }
    }
  }

  void _presentEndDatePicker() {
    //todo change to one function instead of two _presentDatePicker(Controller)
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('select a start date first'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: _selectedStartDate!.add(const Duration(seconds: 1)),
        firstDate: _selectedStartDate!.add(const Duration(seconds: 1)),
        lastDate: DateTime.now().add(Duration(days: 7)),
      ).then((pickedDate) async {
        if (pickedDate != null) {
          if (!context.mounted) return;
          final TimeOfDay? timePicked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (timePicked != null) {
            _selectedStartDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              timePicked.hour,
              timePicked.minute,
            );
          }
          setState(() {
            _selectedEndDate = pickedDate;
          });
        }
      });
    }
  }

  Future<void> _submitData() async {
    if (_talkTitleController.text.isEmpty ||
        _speakerUserController.text.isEmpty ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('provide required information first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    String enteredTitle = _talkTitleController.text;
    String enteredSpeakerUsername = _speakerUserController.text;
    DateTime enteredStartDate = _selectedStartDate!;
    DateTime enteredEndDate = _selectedEndDate!;
    int? talkId = await Request.addTalk(
      context,
      widget.eventId,
      enteredSpeakerUsername,
      enteredTitle,
      enteredStartDate,
      enteredEndDate,
    );
    if (talkId != null) {
      widget.addTalk(Talk.addTalkUsingSpeakerUsername(
        id: talkId,
        title: enteredTitle,
        speakerUsername: enteredSpeakerUsername,
        eventId: widget.eventId,
        start: enteredStartDate,
        end: enteredEndDate,
      ));
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
  }
}
