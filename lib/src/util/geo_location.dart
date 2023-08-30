/*
 * Zmanim Java API
 * Copyright (C) 2004-2018 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// A class that contains location information such as latitude and longitude required for astronomical calculations. The
/// elevation field may not be used by some calculation engines and would be ignored if set. Check the documentation for
/// specific implementations of the {@link AstronomicalCalculator} to see if elevation is calculated as part of the
/// algorithm.
///
/// @author &copy; Eliyahu Hershfeld 2004 - 2018
/// @version 1.1
class GeoLocation {
  /// @see #getLatitude()
  /// @see #setLatitude(double)
  /// @see #setLatitude(int, int, double, String)
  late double _latitude;

  /// @see #getLongitude()
  /// @see #setLongitude(double)
  /// @see #setLongitude(int, int, double, String)
  late double _longitude;
  late String _locationName;
  late DateTime _dateTime;

  /// @see #getElevation()
  /// @see #setElevation(double)
  double? _elevation;

  /// Constant for a distance type calculation.
  /// @see #getGeodesicDistance(GeoLocation)
  static const int _DISTANCE = 0;

  /// Constant for a initial bearing type calculation.
  /// @see #getGeodesicInitialBearing(GeoLocation)
  static const int _INITIAL_BEARING = 1;

  /// Constant for a final bearing type calculation.
  /// @see #getGeodesicFinalBearing(GeoLocation)
  static const int _FINAL_BEARING = 2;

  /// constant for milliseconds in a minute (60,000) */
  static const double _MINUTE_MILLIS = 60 * 1000.0;

  /// constant for milliseconds in an hour (3,600,000) */
  static const double _HOUR_MILLIS = _MINUTE_MILLIS * 60;

  /// Default GeoLocation constructor will set location to the Prime Meridian at Greenwich, England and a TimeZone of
  /// GMT. The longitude will be set to 0 and the latitude will be 51.4772 to match the location of the <a
  /// href="http://www.rog.nmm.ac.uk">Royal Observatory, Greenwich </a>. No daylight savings time will be used.
  GeoLocation() {
    setLocationName("Greenwich, England");
    setLongitude(longitude: 0); // added for clarity
    setLatitude(latitude: 51.4772);
    setDateTime(DateTime.now().toUtc());
  }

  /// GeoLocation constructor with parameters for all required fields.
  ///
  /// @param locationName
  ///            The location name for display use such as "Lakewood, NJ"
  /// @param latitude
  ///            the latitude in a double format such as 40.095965 for Lakewood, NJ.
  ///            <b>Note: </b> For latitudes south of the equator, a negative value should be used.
  /// @param longitude
  ///            double the longitude in a double format such as -74.222130 for Lakewood, NJ.
  ///            <b>Note: </b> For longitudes east of the <a href="http://en.wikipedia.org/wiki/Prime_Meridian">Prime
  ///            Meridian </a> (Greenwich), a negative value should be used.
  /// @param elevation
  ///            the elevation above sea level in Meters. Elevation is not used in most algorithms used for calculating
  ///            sunrise and set.
  /// @param timeZone
  ///            the <code>TimeZone</code> for the location.
  GeoLocation.setLocation(
      String locationName, double latitude, double longitude, DateTime dateTime,
      [double elevation = 0]) {
    setLocationName(locationName);
    setLatitude(latitude: latitude);
    setLongitude(longitude: longitude);
    setElevation(elevation);
    setDateTime(dateTime);
  }

  /// Method to get the elevation in Meters.
  ///
  /// @return Returns the elevation in Meters.
  double? getElevation() {
    return _elevation;
  }

  /// Method to set the elevation in Meters <b>above </b> sea level.
  ///
  /// @param elevation
  ///            The elevation to set in Meters. An IllegalArgumentException will be thrown if the value is a negative.
  void setElevation(double elevation) {
    if (elevation < 0) {
      throw ArgumentError("Elevation cannot be negative");
    }
    _elevation = elevation;
  }

  /// Method to set the latitude in degrees, minutes and seconds.
  ///
  /// @param degrees
  ///            The degrees of latitude to set between 0&deg; and 90&deg;. For example 40 would be used for Lakewood, NJ.
  ///            An IllegalArgumentException will be thrown if the value exceeds the limit.
  /// @param minutes
  ///            <a href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</a>
  /// @param seconds
  ///            <a href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</a>
  /// @param direction
  ///            N for north and S for south. An IllegalArgumentException will be thrown if the value is not S or N.
  void setLatitude(
      {int? degrees,
      int? minutes,
      double? seconds,
      String? direction,
      double? latitude}) {
    if (latitude != null) {
      if (latitude > 90 || latitude < -90) {
        throw ArgumentError("Latitude must be between -90 and  90");
      }
      _latitude = latitude;
    } else if (degrees == null ||
        minutes == null ||
        seconds == null ||
        direction == null) {
      throw ArgumentError(
          "Longitude must be between 0 and  180.  Use a direction of W instead of negative.");
    } else {
      double tempLat = degrees + ((minutes + (seconds / 60.0)) / 60.0);
      if (tempLat > 90 || tempLat < 0) {
        //FIXME An exception should be thrown if degrees, minutes or seconds are negative
        throw ArgumentError(
            "Latitude must be between 0 and  90. Use direction of S instead of negative.");
      }
      if (direction == "S") {
        tempLat *= -1;
      } else if (direction != "N") {
        throw ArgumentError("Latitude direction must be N or S");
      }
      _latitude = tempLat;
    }
  }

  /// @return Returns the latitude.
  double getLatitude() {
    return _latitude;
  }

  /// Method to set the longitude in degrees, minutes and seconds.
  ///
  /// @param degrees
  ///            The degrees of longitude to set between 0&deg; and 180&deg;. As an example 74 would be set for Lakewood, NJ.
  ///            An IllegalArgumentException will be thrown if the value exceeds the limits.
  /// @param minutes
  ///            <a href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</a>
  /// @param seconds
  ///            <a href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</a>
  /// @param direction
  ///            E for east of the <a href="http://en.wikipedia.org/wiki/Prime_Meridian">Prime Meridian </a> or W for west of it.
  ///            An IllegalArgumentException will be thrown if
  ///            the value is not E or W.
  void setLongitude(
      {int? degrees,
      int? minutes,
      double? seconds,
      String? direction,
      double? longitude}) {
    if (longitude != null) {
      if (longitude > 180 || longitude < -180) {
        throw ArgumentError("Longitude must be between -180 and  180");
      }
      _longitude = longitude;
    } else if (degrees == null ||
        minutes == null ||
        seconds == null ||
        direction == null) {
      throw ArgumentError(
          "Longitude must be between 0 and  180.  Use a direction of W instead of negative.");
    } else {
      double longTemp = degrees + ((minutes + (seconds / 60.0)) / 60.0);
      if (longTemp > 180 || _longitude < 0) {
        //FIXME An exception should be thrown if degrees, minutes or seconds are negative
        throw ArgumentError(
            "Longitude must be between 0 and  180.  Use a direction of W instead of negative.");
      }
      if (direction == "W") {
        longTemp *= -1;
      } else if (direction != "E") {
        throw ArgumentError("Longitude direction must be E or W");
      }
      _longitude = longTemp;
    }
  }

  /// @return Returns the longitude.
  double getLongitude() {
    return _longitude;
  }

  /// @return Returns the location name.
  String getLocationName() {
    return _locationName;
  }

  /// @param name
  ///            The setter method for the display name.
  void setLocationName(String name) {
    _locationName = name;
  }

  /// @return Returns the timeZone.
  DateTime getDateTime() {
    return _dateTime;
  }

  /// Method to set the TimeZone. If this is ever set after the GeoLocation is set in the
  /// {@link net.sourceforge.zmanim.AstronomicalCalendar}, it is critical that
  /// {@link net.sourceforge.zmanim.AstronomicalCalendar#getCalendar()}.
  /// {@link java.util.Calendar#setTimeZone(TimeZone) setTimeZone(TimeZone)} be called in order for the
  /// AstronomicalCalendar to output times in the expected offset. This situation will arise if the
  /// AstronomicalCalendar is ever {@link net.sourceforge.zmanim.AstronomicalCalendar#clone() cloned}.
  ///
  /// @param timeZone
  ///            The timeZone to set.
  void setDateTime(DateTime dateTime) {
    _dateTime = dateTime;
  }

  /// A method that will return the location's local mean time offset in milliseconds from local <a
  /// href="http://en.wikipedia.org/wiki/Standard_time">standard time</a>. The globe is split into 360&deg;, with
  /// 15&deg; per hour of the day. For a local that is at a longitude that is evenly divisible by 15 (longitude % 15 ==
  /// 0), at solar {@link net.sourceforge.zmanim.AstronomicalCalendar#getSunTransit() noon} (with adjustment for the <a
  /// href="http://en.wikipedia.org/wiki/Equation_of_time">equation of time</a>) the sun should be directly overhead,
  /// so a user who is 1&deg; west of this will have noon at 4 minutes after standard time noon, and conversely, a user
  /// who is 1&deg; east of the 15&deg; longitude will have noon at 11:56 AM. Lakewood, N.J., whose longitude is
  /// -74.2094, is 0.7906 away from the closest multiple of 15 at -75&deg;. This is multiplied by 4 to yield 3 minutes
  /// and 10 seconds earlier than standard time. The offset returned does not account for the <a
  /// href="http://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</a> offset since this class is
  /// unaware of dates.
  ///
  /// @return the offset in milliseconds not accounting for Daylight saving time. A positive value will be returned
  ///         East of the 15&deg; timezone line, and a negative value West of it.
  /// @since 1.1
  double getLocalMeanTimeOffset() {
    return (getLongitude() * 4 * _MINUTE_MILLIS -
            getDateTime().timeZoneOffset.inMilliseconds)
        .toDouble();
  }

  /// Adjust the date for <a href="https://en.wikipedia.org/wiki/180th_meridian">antimeridian</a> crossover. This is
  /// needed to deal with edge cases such as Samoa that use a different calendar date than expected based on their
  /// geographic location.
  ///
  /// The actual Time Zone offset may deviate from the expected offset based on the longitude. Since the 'absolute time'
  /// calculations are always based on longitudinal offset from UTC for a given date, the date is presumed to only
  /// increase East of the Prime Meridian, and to only decrease West of it. For Time Zones that cross the antimeridian,
  /// the date will be artificially adjusted before calculation to conform with this presumption.
  ///
  /// For example, Apia, Samoa with a longitude of -171.75 uses a local offset of +14:00.  When calculating sunrise for
  /// 2018-02-03, the calculator should operate using 2018-02-02 since the expected zone is -11.  After determining the
  /// UTC time, the local DST offset of <a href="https://en.wikipedia.org/wiki/UTC%2B14:00">UTC+14:00</a> should be applied
  /// to bring the date back to 2018-02-03.
  ///
  /// @return the number of days to adjust the date This will typically be 0 unless the date crosses the antimeridian
  int getAntimeridianAdjustment() {
    double localHoursOffset = getLocalMeanTimeOffset() / _HOUR_MILLIS;

    if (localHoursOffset >= 20) {
      // if the offset is 20 hours or more in the future (never expected anywhere other
      // than a location using a timezone across the anti meridian to the east such as Samoa)
      return 1; // roll the date forward a day
    } else if (localHoursOffset <= -20) {
      // if the offset is 20 hours or more in the past (no current location is known
      //that crosses the antimeridian to the west, but better safe than sorry)
      return -1; // roll the date back a day
    }
    return 0; //99.999% of the world will have no adjustment
  }

  /// Calculate the initial <a href="http://en.wikipedia.org/wiki/Great_circle">geodesic</a> bearing between this
  /// Object and a second Object passed to this method using <a
  /// href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
  /// href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
  /// with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
  ///
  /// @param location
  ///            the destination location
  /// @return the initial bearing
  double getGeodesicInitialBearing(GeoLocation location) {
    return vincentyFormula(location, _INITIAL_BEARING);
  }

  /// Calculate the final <a href="http://en.wikipedia.org/wiki/Great_circle">geodesic</a> bearing between this Object
  /// and a second Object passed to this method using <a href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus
  /// Vincenty's</a> inverse formula See T Vincenty, "<a href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and
  /// Inverse Solutions of Geodesics on the Ellipsoid with application of nested equations</a>", Survey Review, vol
  /// XXII no 176, 1975
  ///
  /// @param location
  ///            the destination location
  /// @return the final bearing
  double getGeodesicFinalBearing(GeoLocation location) {
    return vincentyFormula(location, _FINAL_BEARING);
  }

  /// Calculate <a href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> in Meters between
  /// this Object and a second Object passed to this method using <a
  /// href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
  /// href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
  /// with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
  ///
  /// @see #vincentyFormula(GeoLocation, int)
  /// @param location
  ///            the destination location
  /// @return the geodesic distance in Meters
  double getGeodesicDistance(GeoLocation location) {
    return vincentyFormula(location, _DISTANCE);
  }

  /// Calculate <a href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</a> in Meters between
  /// this Object and a second Object passed to this method using <a
  /// href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</a> inverse formula See T Vincenty, "<a
  /// href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
  /// with application of nested equations</a>", Survey Review, vol XXII no 176, 1975
  ///
  /// @param location
  ///            the destination location
  /// @param formula
  ///            This formula calculates initial bearing ({@link #INITIAL_BEARING}), final bearing (
  ///            {@link #FINAL_BEARING}) and distance ({@link #DISTANCE}).
  /// @return geodesic distance in Meters
  double vincentyFormula(GeoLocation location, int formula) {
    double a = 6378137;
    double b = 6356752.3142;
    double f = 1 / 298.257223563; // WGS-84 ellipsiod
    double L = radians(location.getLongitude() - getLongitude());
    double u1 = atan((1 - f) * tan(radians(getLatitude())));
    double u2 = atan((1 - f) * tan(radians(location.getLatitude())));
    double sinU1 = sin(u1), cosU1 = cos(u1);
    double sinU2 = sin(u2), cosU2 = cos(u2);

    double lambda = L;
    double lambdaP = 2 * pi;
    double iterLimit = 20;
    double sinLambda = 0;
    double cosLambda = 0;
    double sinSigma = 0;
    double cosSigma = 0;
    double sigma = 0;
    double sinAlpha = 0;
    double cosSqAlpha = 0;
    double cos2SigmaM = 0;
    double C;
    while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0) {
      sinLambda = sin(lambda);
      cosLambda = cos(lambda);
      sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
      if (sinSigma == 0) return 0; // co-incident points
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      if (cos2SigmaM.isNaN) {
        cos2SigmaM = 0;
      } // equatorial line: cosSqAlpha=0 (§6)
      C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L +
          (1 - C) *
              f *
              sinAlpha *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SigmaM +
                          C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    }
    if (iterLimit == 0) return double.nan; // formula failed to converge

    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A =
        1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B *
        sinSigma *
        (cos2SigmaM +
            B /
                4 *
                (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
                    B /
                        6 *
                        cos2SigmaM *
                        (-3 + 4 * sinSigma * sinSigma) *
                        (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    double distance = b * A * (sigma - deltaSigma);

    // initial bearing
    double fwdAz = degrees(
        atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
    // final bearing
    double revAz = degrees(
        atan2(cosU1 * sinLambda, -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda));
    if (formula == _DISTANCE) {
      return distance;
    } else if (formula == _INITIAL_BEARING) {
      return fwdAz;
    } else if (formula == _FINAL_BEARING) {
      return revAz;
    } else {
      // should never happen
      return double.nan;
    }
  }

  /// Returns the <a href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a> bearing from the current location to
  /// the GeoLocation passed in.
  ///
  /// @param location
  ///            destination location
  /// @return the bearing in degrees
  double getRhumbLineBearing(GeoLocation location) {
    double dLon = radians(location.getLongitude() - getLongitude());
    double dPhi = log(tan(radians(location.getLatitude()) / 2 + pi / 4) /
        tan(radians(getLatitude()) / 2 + pi / 4));
    if (dLon.abs() > pi) dLon = dLon > 0 ? -(2 * pi - dLon) : (2 * pi + dLon);
    return degrees(atan2(dLon, dPhi));
  }

  /// Returns the <a href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</a> distance from the current location
  /// to the GeoLocation passed in.
  ///
  /// @param location
  ///            the destination location
  /// @return the distance in Meters
  double getRhumbLineDistance(GeoLocation location) {
    double earthRadius = 6378137; // Earth's radius in meters (WGS-84)
    double dLat = radians(location.getLatitude()) - radians(getLatitude());
    double dLon =
        (radians(location.getLongitude()) - radians(getLongitude())).abs();
    double dPhi = log(tan(radians(location.getLatitude()) / 2 + pi / 4) /
        tan(radians(getLatitude()) / 2 + pi / 4));
    double q = dLat / dPhi;

    if (!(q.abs() <= double.maxFinite)) {
      q = cos(radians(getLatitude()));
    }
    // if dLon over 180° take shorter rhumb across 180° meridian:
    if (dLon > pi) {
      dLon = 2 * pi - dLon;
    }
    double d = sqrt(dLat * dLat + q * q * dLon * dLon);
    return d * earthRadius;
  }

/*
  /// A method that returns an XML formatted <code>String</code> representing the serialized <code>Object</code>. Very
  /// similar to the toString method but the return value is in an xml format. The format currently used (subject to
  /// change) is:
  ///
  /// <pre>
  ///   &lt;GeoLocation&gt;
  ///   	 &lt;LocationName&gt;Lakewood, NJ&lt;/LocationName&gt;
  ///   	 &lt;Latitude&gt;40.0828&amp;deg&lt;/Latitude&gt;
  ///   	 &lt;Longitude&gt;-74.2094&amp;deg&lt;/Longitude&gt;
  ///   	 &lt;Elevation&gt;0 Meters&lt;/Elevation&gt;
  ///   	 &lt;TimezoneName&gt;America/New_York&lt;/TimezoneName&gt;
  ///   	 &lt;TimeZoneDisplayName&gt;Eastern Standard Time&lt;/TimeZoneDisplayName&gt;
  ///   	 &lt;TimezoneGMTOffset&gt;-5&lt;/TimezoneGMTOffset&gt;
  ///   	 &lt;TimezoneDSTOffset&gt;1&lt;/TimezoneDSTOffset&gt;
  ///   &lt;/GeoLocation&gt;
  /// </pre>
  ///
  /// @return The XML formatted <code>String</code>.
  String toXML() {
    StringBuffer sb = new StringBuffer();
    sb.append("<GeoLocation>\n");
    sb.append("\t<LocationName>").append(getLocationName()).append("</LocationName>\n");
    sb.append("\t<Latitude>").append(getLatitude()).append("</Latitude>\n");
    sb.append("\t<Longitude>").append(getLongitude()).append("</Longitude>\n");
    sb.append("\t<Elevation>").append(getElevation()).append(" Meters").append("</Elevation>\n");
    sb.append("\t<TimezoneName>").append(getTimeZone().getID()).append("</TimezoneName>\n");
    sb.append("\t<TimeZoneDisplayName>").append(getTimeZone().getDisplayName()).append("</TimeZoneDisplayName>\n");
    sb.append("\t<TimezoneGMTOffset>").append(getTimeZone().getRawOffset() / _HOUR_MILLIS)
        .append("</TimezoneGMTOffset>\n");
    sb.append("\t<TimezoneDSTOffset>").append(getTimeZone().getDSTSavings() / _HOUR_MILLIS)
        .append("</TimezoneDSTOffset>\n");
    sb.append("</GeoLocation>");
    return sb.toString();
  }
*/

  /// @see java.lang.Object#equals(Object)
  @override
  bool operator ==(Object object) {
    if (identical(this, object)) {
      return true;
    }
    try {
      GeoLocation geo = object as GeoLocation;
      return _latitude == geo._latitude &&
          _longitude == geo._longitude &&
          _elevation == geo._elevation &&
          (_locationName == geo._locationName) &&
          (_dateTime == geo._dateTime);
    } catch (e) {
      return false;
    }
  }

  ///@see Object#hashCode()
  @override
  int get hashCode {
    int result = 17;
    int latInt = _latitude.toInt() ^ (_latitude * 10000).round();
    int lonInt = _longitude.toInt() ^ (_longitude * 10000).round();
    int elevInt = _elevation?.toInt() ?? 0 ^ (_elevation ?? 0 * 10000).round();
    result = 37 * result + runtimeType.hashCode;
    result += 37 * result + latInt;
    result += 37 * result + lonInt;
    result += 37 * result + elevInt;
    result += 37 * result + _locationName.hashCode;
    result += 37 * result + _dateTime.hashCode;
    return result;
  }
/*
  /// @see java.lang.Object#toString()
  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append("\nLocation Name:\t\t\t").append(getLocationName());
    sb.append("\nLatitude:\t\t\t").append(getLatitude()).append("\u00B0");
    sb.append("\nLongitude:\t\t\t").append(getLongitude()).append("\u00B0");
    sb.append("\nElevation:\t\t\t").append(getElevation()).append(" Meters");
    sb.append("\nTimezone ID:\t\t\t").append(getTimeZone().getID());
    sb.append("\nTimezone Display Name:\t\t").append(getTimeZone().getDisplayName())
        .append(" (").append(getTimeZone().getDisplayName(false, TimeZone.SHORT)).append(")");
    sb.append("\nTimezone GMT Offset:\t\t").append(getTimeZone().getRawOffset() / _HOUR_MILLIS);
    sb.append("\nTimezone DST Offset:\t\t").append(getTimeZone().getDSTSavings() / _HOUR_MILLIS);
    return sb.toString();
  }
*/

  /// Create clone of this GeoLocation
  GeoLocation clone() {
    return GeoLocation.setLocation(getLocationName(), getLatitude(),
        getLongitude(), DateTime.parse(getDateTime().toIso8601String()));
  }
}
