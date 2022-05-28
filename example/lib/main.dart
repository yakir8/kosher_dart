import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  JewishDate jewishDate = JewishDate();
  JewishCalendar jewishCalendar = JewishCalendar();
  HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kosher Dart'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(' תאריך לעוזי: ' +
                  DateFormat("dd.MM.yyyy")
                      .format(jewishDate.getGregorianCalendar())),
            ),
            Center(
              child:
                  Text('תאריך עברי: ' + hebrewDateFormatter.format(jewishDate)),
            ),
            Center(
              child: Text('פרשת השבוע: ' +
                  hebrewDateFormatter.formatWeeklyParsha(jewishCalendar)),
            ),
          ],
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
