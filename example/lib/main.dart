import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  JewishDate jewishDate = JewishDate();
  JewishCalendar jewishCalendar = JewishCalendar();
  HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();
  HebrewDateFormatter translatedDateFormatter = HebrewDateFormatter()
    ..hebrewFormat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kosher Dart'),
      ),
      body: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: jewishCalendar.getGregorianCalendar(),
            firstDate: DateTime(jewishCalendar.getGregorianYear() - 100),
            lastDate: DateTime(jewishCalendar.getGregorianYear() + 100),
          );

          if (pickedDate != null) {
            setState(() {
              jewishCalendar.setDate(pickedDate);
              jewishDate.setDate(pickedDate);
            });
          }
        },
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(' תאריך לעוזי: ${DateFormat("dd.MM.yyyy")
                      .format(jewishDate.getGregorianCalendar())}'),
              Text('תאריך עברי: ${hebrewDateFormatter.format(jewishDate)}'),
              Text('פרשת השבוע: ${hebrewDateFormatter.formatWeeklyParsha(jewishCalendar)}'),
              Text('דף יומי: ${hebrewDateFormatter.formatDafYomiBavli(
                      jewishCalendar.getDafYomiBavli())}'),
              Text('Daf Yomi: ${hebrewDateFormatter.formatDafYomiBavli(
                      jewishCalendar.getDafYomiBavli())}'),
              Text('Translated Hebrew Date: ${translatedDateFormatter.format(jewishDate)}'),
              Text('Cloned Translated Hebrew Date: ${translatedDateFormatter.format(jewishDate.clone())}'),
              Text('Parasha of the week: ${translatedDateFormatter.formatWeeklyParsha(jewishCalendar)}'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    hebrewDateFormatter.hebrewFormat = true;
    hebrewDateFormatter.useGershGershayim = true;
    super.initState();
  }
}
