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
  HebrewDateFormatter translatedDateFormatter = HebrewDateFormatter()
    ..hebrewFormat = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kosher Dart'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(' תאריך לעוזי: ' +
                  DateFormat("dd.MM.yyyy")
                      .format(jewishDate.getGregorianCalendar())),
              Text('תאריך עברי: ' + hebrewDateFormatter.format(jewishDate)),
              Text('פרשת השבוע: ' +
                  hebrewDateFormatter.formatWeeklyParsha(jewishCalendar)),
              Text('Translated Hebrew Date: ' +
                  translatedDateFormatter.format(jewishDate)),
              Text('Parasha of the week: ' +
                  translatedDateFormatter.formatWeeklyParsha(jewishCalendar)),
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
