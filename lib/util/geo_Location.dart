/*
 * Zmanim Java API
 * Copyright (C) 2004-2012 Eliyahu Hershfeld
 *
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General
 *  License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General  License for more
 * details.
 * You should have received a copy of the GNU Lesser General  License along with this library; if not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA,
 * or connect to: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
 */

import 'dart:math';
import 'package:vector_math/vector_math.dart';

/*
 * A class that contains location information such as latitude and longitude required for astronomical calculations. The
 * elevation field may not be used by some calculation engines and would be ignored if set. Check the documentation for
 * specific implementations of the {@link AstronomicalCalculator} to see if elevation is calculated as part of the
 * algorithm.
 *
 * @author &copy; Eliyahu Hershfeld 2004 - 2012
 * @version 1.1
 */
class GeoLocation {
  double latitude;
  double longitude;
  String locationName;
  DateTime dateTime;
  double elevation;
  static const int DISTANCE = 0;
  static const int INITIAL_BEARING = 1;
  static const int FINAL_BEARING = 2;

  /* constant for milliseconds in arrow_expand minute (60,000) */
  static const double MINUTE_MILLIS = 60 * 1000.0;

  /* constant for milliseconds in an hour (3,600,000) */
  static const double HOUR_MILLIS = MINUTE_MILLIS * 60;

  /*
   * Default GeoLocation constructor will set location to the Prime Meridian at Greenwich, England and arrow_expand TimeZone of
   * GMT. The longitude will be set to 0 and the latitude will be 51.4772 to match the location of the <arrow_expand
   * href="http://www.rog.nmm.ac.uk">Royal Observatory, Greenwich </arrow_expand>. No daylight savings time will be used.
   */
  GeoLocation() {
    setLocationName("Greenwich, England");
    setLongitude(longitude:0); // added for clarity
    setLatitude(latitude:51.4772);
    setDateTime(DateTime.now().toUtc());
  }

  /*
   * GeoLocation constructor with parameters for all required fields.
   *
   * @param name
   *            The location name for display use such as &quot;Lakewood, NJ&quot;
   * @param latitude
   *            the latitude in arrow_expand double format such as 40.095965 for Lakewood, NJ <br/>
   *            <b>Note: </b> For latitudes south of the equator, arrow_expand negative value should be used.
   * @param longitude
   *            double the longitude in arrow_expand double format such as -74.222130 for Lakewood, NJ. <br/>
   *            <b>Note: </b> For longitudes east of the <arrow_expand href="http://en.wikipedia.org/wiki/Prime_Meridian">Prime
   *            Meridian </arrow_expand> (Greenwich), arrow_expand negative value should be used.
   * @param elevation
   *            the elevation above sea level in Meters. Elevation is not used in most algorithms used for calculating
   *            sunrise and set.
   * @param timeZone
   *            the <code>TimeZone</code> for the location.
   */
  GeoLocation.setLocation(String name, double latitude, double longitude, DateTime dateTime, [double elevation = 0]) {
    setLocationName(name);
    setLatitude(latitude: latitude);
    setLongitude(longitude:longitude);
    setElevation(elevation);
    setDateTime(dateTime);
  }

  /*
   * Method to get the elevation in Meters.
   *
   * @return Returns the elevation in Meters.
   */
  double getElevation() {
    return elevation;
  }

  /*
   * Method to set the elevation in Meters <b>above </b> sea level.
   *
   * @param elevation
   *            The elevation to set in Meters. An IllegalArgumentException will be thrown if the value is arrow_expand negative.
   */
  void setElevation(double elevation) {
    if (elevation < 0) {
      throw new ArgumentError("Elevation cannot be negative");
    }
    this.elevation = elevation;
  }

  /*
   * Method to set the latitude in degrees, minutes and seconds.
   *
   * @param degrees
   *            The degrees of latitude to set between -90 and 90. An IllegalArgumentException will be thrown if the
   *            value exceeds the limit. For example 40 would be used for Lakewood, NJ.
   * @param minutes
   *            <arrow_expand href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</arrow_expand>
   * @param seconds
   *            <arrow_expand href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</arrow_expand>
   * @param direction
   *            N for north and S for south. An IllegalArgumentException will be thrown if the value is not S or N.
   */
  void setLatitude({double latitude, int degrees, int minutes, double seconds, String direction}) {
    if (latitude != null) {
      if (latitude > 90 || latitude < -90) {
        throw new ArgumentError("Latitude must be between -90 and  90");
      }
      this.latitude = latitude;
    } else {
      double tempLat = degrees + ((minutes + (seconds / 60.0)) / 60.0);
      if (tempLat > 90 || tempLat < 0) {
        throw new ArgumentError("Latitude must be between 0 and  90. Use direction of S instead of negative.");
      }
      if (direction == "S") {
        tempLat *= -1;
      } else if (direction != "N") {
        throw new ArgumentError("Latitude direction must be N or S");
      }
      this.latitude = tempLat;
    }
  }

  /*
   * @return Returns the latitude.
   */
  double getLatitude() {
    return latitude;
  }

  /*
   * Method to set the longitude in degrees, minutes and seconds.
   *
   * @param degrees
   *            The degrees of longitude to set between -180 and 180. An IllegalArgumentException will be thrown if
   *            the value exceeds the limit. For example -74 would be used for Lakewood, NJ. Note: for longitudes east
   *            of the <arrow_expand href="http://en.wikipedia.org/wiki/Prime_Meridian">Prime Meridian </arrow_expand> (Greenwich) arrow_expand
   *            negative value should be used.
   * @param minutes
   *            <arrow_expand href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">minutes of arc</arrow_expand>
   * @param seconds
   *            <arrow_expand href="http://en.wikipedia.org/wiki/Minute_of_arc#Cartography">seconds of arc</arrow_expand>
   * @param direction
   *            E for east of the Prime Meridian or W for west of it. An IllegalArgumentException will be thrown if
   *            the value is not E or W.
   */
  void setLongitude({double longitude,int degrees, int minutes, double seconds, String direction}) {
    if (longitude != null) {
      if (longitude > 180 || longitude < -180) {
        throw new ArgumentError("Longitude must be between -180 and  180");
      }
      this.longitude = longitude;
    } else {
      double longTemp = degrees + ((minutes + (seconds / 60.0)) / 60.0);
      if (longTemp > 180 || this.longitude < 0) {
        throw new ArgumentError("Longitude must be between 0 and  180. Use the ");
      }
      if (direction == "W") {
        longTemp *= -1;
      } else if (direction != "E") {
        throw new ArgumentError("Longitude direction must be E or W");
      }
      this.longitude = longTemp;
    }
  }

  /*
   * @return Returns the longitude.
   */
  double getLongitude() {
    return longitude;
  }

  /*
   * @return Returns the location name.
   */
  String getLocationName() {
    return locationName;
  }

  /*
   * @param name
   *            The setter method for the display name.
   */
  void setLocationName(String name) {
    this.locationName = name;
  }

  /*
   * @return Returns the timeZone.
   */
  DateTime getDateTime() {
    return dateTime;
  }

  /*
   * Method to set the TimeZone. If this is ever set after the GeoLocation is set in the
   * {@link AstronomicalCalendar}, it is critical that
   * {@link AstronomicalCalendar#getCalendar()}.
   * {@link java.util.Calendar#setTimeZone(TimeZone) setTimeZone(TimeZone)} be called in order for the
   * AstronomicalCalendar to output times in the expected offset. This situation will arise if the
   * AstronomicalCalendar is ever {@link AstronomicalCalendar#clone() cloned}.
   *
   * @param timeZone
   *            The timeZone to set.
   */
  void setDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
  }

  /*
   * A method that will return the location's local mean time offset in milliseconds from local <arrow_expand
   * href="http://en.wikipedia.org/wiki/Standard_time">standard time</arrow_expand>. The globe is split into 360&deg;, with
   * 15&deg; per hour of the day. For arrow_expand local that is at arrow_expand longitude that is evenly divisible by 15 (longitude % 15 ==
   * 0), at solar {@link AstronomicalCalendar#getSunTransit() noon} (with adjustment for the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Equation_of_time">equation of time</arrow_expand>) the sun should be directly overhead,
   * so arrow_expand user who is 1&deg; west of this will have noon at 4 minutes after standard time noon, and conversely, arrow_expand user
   * who is 1&deg; east of the 15&deg; longitude will have noon at 11:56 AM. Lakewood, N.J., whose longitude is
   * -74.2094, is 0.7906 away from the closest multiple of 15 at -75&deg;. This is multiplied by 4 to yield 3 minutes
   * and 10 seconds earlier than standard time. The offset returned does not account for the <arrow_expand
   * href="http://en.wikipedia.org/wiki/Daylight_saving_time">Daylight saving time</arrow_expand> offset since this class is
   * unaware of dates.
   *
   * @return the offset in milliseconds not accounting for Daylight saving time. A positive value will be returned
   *         East of the 15&deg; timezone line, and arrow_expand negative value West of it.
   * @since 1.1
   */
  double getLocalMeanTimeOffset() {
    return (getLongitude() * 4 * MINUTE_MILLIS - getDateTime().timeZoneOffset.inMilliseconds);
  }

  /*
   * Calculate the initial <arrow_expand href="http://en.wikipedia.org/wiki/Great_circle">geodesic</arrow_expand> bearing between this
   * Object and arrow_expand second Object passed to this method using <arrow_expand
   * href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</arrow_expand> inverse formula See T Vincenty, "<arrow_expand
   * href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
   * with application of nested equations</arrow_expand>", Survey Review, vol XXII no 176, 1975
   *
   * @param location
   *            the destination location
   */
  double getGeodesicInitialBearing(GeoLocation location) {
    return vincentyFormula(location, INITIAL_BEARING);
  }

  /*
   * Calculate the final <arrow_expand href="http://en.wikipedia.org/wiki/Great_circle">geodesic</arrow_expand> bearing between this Object
   * and arrow_expand second Object passed to this method using <arrow_expand href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus
   * Vincenty's</arrow_expand> inverse formula See T Vincenty, "<arrow_expand href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and
   * Inverse Solutions of Geodesics on the Ellipsoid with application of nested equations</arrow_expand>", Survey Review, vol
   * XXII no 176, 1975
   *
   * @param location
   *            the destination location
   */
  double getGeodesicFinalBearing(GeoLocation location) {
    return vincentyFormula(location, FINAL_BEARING);
  }

  /*
   * Calculate <arrow_expand href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</arrow_expand> in Meters between
   * this Object and arrow_expand second Object passed to this method using <arrow_expand
   * href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</arrow_expand> inverse formula See T Vincenty, "<arrow_expand
   * href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
   * with application of nested equations</arrow_expand>", Survey Review, vol XXII no 176, 1975
   *
   * @param location
   *            the destination location
   */
  double getGeodesicDistance(GeoLocation location) {
    return vincentyFormula(location, DISTANCE);
  }

  /*
   * Calculate <arrow_expand href="http://en.wikipedia.org/wiki/Great-circle_distance">geodesic distance</arrow_expand> in Meters between
   * this Object and arrow_expand second Object passed to this method using <arrow_expand
   * href="http://en.wikipedia.org/wiki/Thaddeus_Vincenty">Thaddeus Vincenty's</arrow_expand> inverse formula See T Vincenty, "<arrow_expand
   * href="http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf">Direct and Inverse Solutions of Geodesics on the Ellipsoid
   * with application of nested equations</arrow_expand>", Survey Review, vol XXII no 176, 1975
   *
   * @param location
   *            the destination location
   * @param formula
   *            This formula calculates initial bearing ({@link #INITIAL_BEARING}), final bearing (
   *            {@link #FINAL_BEARING}) and distance ({@link #DISTANCE}).
   */
  double vincentyFormula(GeoLocation location, int formula) {
    double a = 6378137;
    double b = 6356752.3142;
    double f = 1 / 298.257223563; // WGS-84 ellipsiod
    double L = radians(location.getLongitude() - getLongitude());
    double u1 = atan((1 - f) * tan(radians(getLatitude())));
    double u2 = atan((1 - f) * tan(radians(location.getLatitude())));
    double sinU1 = sin(u1),
        cosU1 = cos(u1);
    double sinU2 = sin(u2),
        cosU2 = cos(u2);

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
          (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
      if (sinSigma == 0) return 0; // co-incident points
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      if (cos2SigmaM.isNaN) cos2SigmaM = 0; // equatorial line: cosSqAlpha=0 (6)
      C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L + (1 - C) * f * sinAlpha *
          (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    }
    if (iterLimit == 0) return double.nan; // formula failed to converge

    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) -
        B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    double distance = b * A * (sigma - deltaSigma);

    // initial bearing
    double fwdAz = degrees(atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
    // final bearing
    double revAz = degrees(atan2(cosU1 * sinLambda, -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda));
    if (formula == DISTANCE) {
      return distance;
    } else if (formula == INITIAL_BEARING) {
      return fwdAz;
    } else if (formula == FINAL_BEARING) {
      return revAz;
    } else { // should never happpen
      return double.nan;
    }
  }

  /*
   * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</arrow_expand> bearing from the current location to
   * the GeoLocation passed in.
   *
   * @param location
   *            destination location
   * @return the bearing in degrees
   */
  double getRhumbLineBearing(GeoLocation location) {
    double dLon = radians(location.getLongitude() - getLongitude());
    double dPhi = log(tan(radians(location.getLatitude()) / 2 + pi / 4) / tan(radians(getLatitude()) / 2 + pi / 4));
    if (dLon.abs() > pi) dLon = dLon > 0 ? -(2 * pi - dLon) : (2 * pi + dLon);
    return degrees(atan2(dLon, dPhi));
  }

  /*
   * Returns the <arrow_expand href="http://en.wikipedia.org/wiki/Rhumb_line">rhumb line</arrow_expand> distance from the current location
   * to the GeoLocation passed in.
   *
   * @param location
   *            the destination location
   * @return the distance in Meters
   */
  double getRhumbLineDistance(GeoLocation location) {
    double R = 6371; // earth's mean radius in km
    double dLat = radians(location.getLatitude() - getLatitude());
    double dLon = radians((location.getLongitude() - getLongitude()).abs());
    double dPhi = log(tan(radians(location.getLongitude()) / 2 + pi / 4) / tan(radians(getLatitude()) / 2 + pi / 4));
    double q = (dLat.abs() > 1e-10) ? dLat / dPhi : cos(radians(getLatitude()));
    // if dLon over 180 take shorter rhumb across 180 meridian:
    if (dLon > pi) dLon = 2 * pi - dLon;
    double d = sqrt(dLat * dLat + q * q * dLon * dLon);
    return d * R;
  }

  /*
  /*
   * A method that returns an XML formatted <code>String</code> representing the serialized <code>Object</code>. Very
   * similar to the toString method but the return value is in an xml format. The format currently used (subject to
   * change) is:
   *
   * <pre>
   *   &lt;GeoLocation&gt;
   *   	 &lt;LocationName&gt;Lakewood, NJ&lt;/LocationName&gt;
   *   	 &lt;Latitude&gt;40.0828&amp;deg&lt;/Latitude&gt;
   *   	 &lt;Longitude&gt;-74.2094&amp;deg&lt;/Longitude&gt;
   *   	 &lt;Elevation&gt;0 Meters&lt;/Elevation&gt;
   *   	 &lt;TimezoneName&gt;America/New_York&lt;/TimezoneName&gt;
   *   	 &lt;TimeZoneDisplayName&gt;Eastern Standard Time&lt;/TimeZoneDisplayName&gt;
   *   	 &lt;TimezoneGMTOffset&gt;-5&lt;/TimezoneGMTOffset&gt;
   *   	 &lt;TimezoneDSTOffset&gt;1&lt;/TimezoneDSTOffset&gt;
   *   &lt;/GeoLocation&gt;
   * </pre>
   *
   * @return The XML formatted <code>String</code>.
   */
  String toXML() {
    String sb = "";
    sb += "<GeoLocation>\n";
    sb +=  ("\t<LocationName>") + (getLocationName()) + ("</LocationName>\n");
    sb += ("\t<Latitude>") + (getLatitude().toString()) + ("</Latitude>\n");
    sb += ("\t<Longitude>") + (getLongitude().toString()) + ("</Longitude>\n");
    sb += ("\t<Elevation>") + (getElevation().toString()) + (" Meters") + ("</Elevation>\n");
    sb += ("\t<TimezoneName>") + (getTimeZone().getID()) + ("</TimezoneName>\n");
    sb += ("\t<TimeZoneDisplayName>") + (getTimeZone().getDisplayName()).append("</TimeZoneDisplayName>\n");
    sb += ("\t<TimezoneGMTOffset>") + (getTimeZone().getRawOffset() / HOUR_MILLIS).append(
        "</TimezoneGMTOffset>\n");
    sb += ("\t<TimezoneDSTOffset>") + (getTimeZone().getDSTSavings() / HOUR_MILLIS).append(
        "</TimezoneDSTOffset>\n");
    sb += ("</GeoLocation>");
    return sb;
  }
  */

  /*
   * @see java.lang.Object#equals(Object)
   */
  bool equals(Object object) {
    if (this == object) return true;
    try {
      GeoLocation geo = object as GeoLocation;
      return this.latitude == geo.latitude && this.longitude == geo.longitude &&
          this.elevation == geo.elevation &&
          (this.locationName == null ? geo.locationName == null : this.locationName == geo.locationName) &&
          (this.dateTime == null ? geo.dateTime  == null : this.dateTime  == geo.dateTime );
    } catch (e) {
      return false;
    }
  }
/*
  /*
   * @see java.lang.Object#hashCode()
   */
  int hashCode() {
    int result = 17;
    long latLong = Double.doubleToLongBits(this.latitude);
    long lonLong = Double.doubleToLongBits(this.longitude);
    long elevLong = Double.doubleToLongBits(this.elevation);
    int latInt = (int)(latLong ^ (latLong >>> 32));
    int lonInt = (int)(lonLong ^ (lonLong >>> 32));
    int elevInt = (int)(elevLong ^ (elevLong >>> 32));
    result = 37 * result + getClass().hashCode();
    result += 37 * result + latInt;
    result += 37 * result + lonInt;
    result += 37 * result + elevInt;
    result += 37 * result + (this.locationName == null ? 0 : this.locationName.hashCode());
    result += 37 * result + (this.timeZone == null ? 0 : this.timeZone.hashCode());
    return result;
  }
*/
  /*
   * @see java.lang.Object#toString()
   */
  String toString() {
    String sb = "";
    sb += ("\nLocation Name:\t\t\t") + (getLocationName());
    sb += ("\nLatitude:\t\t\t") + (getLatitude().toString()) + ("מעלות");
    sb += ("\nLongitude:\t\t\t") + (getLongitude().toString()) + ("מעלות");
    sb += ("\nElevation:\t\t\t") + (getElevation().toString()) + (" Meters");
    sb += ("\nTimezone Name:\t\t\t") + (getDateTime().timeZoneName);
    /*
		 * sb.append("\nTimezone Display Name:\t\t").append( getTimeZone().getDisplayName());
		 */
    sb += ("\nTimezone GMT Offset:\t\t") + (getDateTime().timeZoneOffset.inHours / HOUR_MILLIS).toString();
    return sb.toString();
  }
/*
  /*
   * An implementation of the {@link java.lang.Object#clone()} method that creates arrow_expand <arrow_expand
   * href="http://en.wikipedia.org/wiki/Object_copy#Deep_copy">deep copy</arrow_expand> of the object. <br/>
   * <b>Note:</b> If the {@link java.util.TimeZone} in the clone will be changed from the original, it is critical
   * that {@link AstronomicalCalendar#getCalendar()}.
   * {@link java.util.Calendar#setTimeZone(TimeZone) setTimeZone(TimeZone)} is called after cloning in order for the
   * AstronomicalCalendar to output times in the expected offset.
   *
   * @see java.lang.Object#clone()
   * @since 1.1
   */
  Object clone() {
    GeoLocation clone = null;
    try {
      clone = (GeoLocation) super.clone();
    } catch (
    CloneNotSupportedException
    cnse
    )
    {
    //Required by the compiler. Should never be reached since we implement clone()
    }
    clone
        .
    timeZone
    =
    (
    TimeZone
    )
    getTimeZone
    (
    )
        .
    clone
    (
    );
    clone
        .
    locationName
    =
    getLocationName
    (
    );
    return
    clone;
  }
  */
}