# kosher_dart API

This API for a specialized calendar that can calculate different astronomical times including sunrise and sunset and Jewish zmanim or religious times for prayers and other Jewish religious dutuies.
This API Translated [KosherJava Zmanim API](https://github.com/KosherJava/zmanim) from JAVA to Dart language.

## License

The library is released under the LGPL 2.1 license.

## Getting Started

Add this to your package's pubspec.yaml file:
``` pubspec.yaml
dependencies:
  kosher_dart: ^2.0.18
```

## Usage
#### Import the package
To use this plugin, follow the plugin [installation instructions](https://pub.dev/packages/kosher_dart/install).
#### Use the plugin
Add the following import to your Dart code:
```
import 'package:kosher_dart/kosher_dart.dart';
```

##### Get Hebrew date
```
  JewishDate jewishDate = JewishDate();
  HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();
  hebrewDateFormatter.hebrewFormat = true; // optional
  hebrewDateFormatter.useGershGershayim = true; // optional
  String hebrewDate = hebrewDateFormatter.format(jewishDate);
```
##### Get jewish holiday
```
  JewishCalendar jewishCalendar = JewishCalendar();
  HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();
  
  jewishCalendar.inIsrael = true; // set to true if your location is in israel
  hebrewDateFormatter.hebrewFormat = true; // optional
  hebrewDateFormatter.useGershGershayim = true; // optional
  
  String yomTov = hebrewDateFormatter.formatYomTov(jewishCalendar);
```

##### Get time of the day
```
  GeoLocation geoLocation = GeoLocation.setLocation(
        'Jerusalem', 31.7962419, 35.2453988, DateTime.now());
    ComplexZmanimCalendar complexZmanimCalendar = ComplexZmanimCalendar.intGeoLocation(geoLocation);
    DateTime? sofZmanTfila = complexZmanimCalendar.getSofZmanTfilaGRA();
    DateTime? minchaKetana = complexZmanimCalendar.getMinchaKetana();
```